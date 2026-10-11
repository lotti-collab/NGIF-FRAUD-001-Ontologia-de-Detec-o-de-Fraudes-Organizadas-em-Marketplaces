"""NGIF-FRAUD-001 Sprint 01: mechanism-oriented synthetic marketplace.
Run: python src/generate.py --output data --seed 42
Only synthetic records; no fraud labels are generated in this sprint.
"""
import argparse
import csv
import hashlib
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path
import numpy as np

START = datetime(2026, 1, 1, tzinfo=timezone.utc)
REGIONS = ('norte', 'sul', 'leste', 'oeste', 'centro')
CATEGORIES = ('refeicoes', 'pizza', 'lanches', 'saudavel', 'mercado')

def save_csv(path, records, fields):
    with path.open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(records)

def iso(dt):
    return dt.isoformat(timespec='seconds')

def generate(output: Path, seed: int, n_clients: int, n_restaurants: int, target_mean: float, days: int):
    rng = np.random.default_rng(seed)
    output.mkdir(parents=True, exist_ok=True)
    # Latent household groups, independent of any fraud mechanism.
    clients, households, devices, sessions, orders, restaurants = [], [], [], [], [], []
    idx = 0
    hid = 0
    while idx < n_clients:
        hid += 1
        size = min(int(rng.choice([1, 2, 3, 4], p=[.49, .32, .15, .04])), n_clients - idx)
        region = str(rng.choice(REGIONS))
        device_id = f'D{hid:06d}'
        households.append({'household_id': f'H{hid:06d}', 'region': region, 'shared_device_id': device_id})
        devices.append({'device_id': device_id, 'device_type': str(rng.choice(['android','ios','web'], p=[.62,.30,.08]))})
        for _ in range(size):
            idx += 1
            profile = str(rng.choice(['ocasional','regular','intensivo'], p=[.45,.43,.12]))
            clients.append({'cliente_id': f'C{idx:06d}', 'household_id': f'H{hid:06d}',
                            'region': region, 'perfil': profile,
                            'data_criacao': iso(START - timedelta(days=int(rng.integers(1, 1100))))})
    for i in range(n_restaurants):
        category = str(rng.choice(CATEGORIES))
        region = str(rng.choice(REGIONS))
        popularity = float(rng.lognormal(0, .85))
        base_price = {'refeicoes': 43, 'pizza': 68, 'lanches': 31, 'saudavel': 47, 'mercado': 76}[category]
        restaurants.append({'restaurante_id': f'R{i+1:04d}', 'region': region,
                            'categoria': category, 'preco_base': base_price,
                            'popularidade': round(popularity, 5)})
    # Poisson-Gamma mixture yields negative-binomial-like overdispersion.
    activity_weights = {'ocasional': .38, 'regular': 1.0, 'intensivo': 2.6}
    avg_weight = sum({'ocasional': .45, 'regular': .43, 'intensivo': .12}[p] * w for p,w in activity_weights.items())
    order_id = 0
    session_id = 0
    hour_weights = np.array([.012,.005,.003,.003,.004,.008,.018,.026,.036,.046,.068,.100,
                             .095,.063,.048,.042,.050,.071,.096,.102,.083,.054,.036,.031])
    hour_weights /= hour_weights.sum()
    for client in clients:
        mean = target_mean * activity_weights[client['perfil']] / avg_weight
        intensity = rng.gamma(shape=2.0, scale=mean/2.0)
        n_orders = int(rng.poisson(intensity))
        weights = np.array([float(r['popularidade']) * (3.0 if r['region'] == client['region'] else .15) for r in restaurants])
        weights /= weights.sum()
        household_device = households[int(client['household_id'][1:])-1]['shared_device_id']
        for _ in range(n_orders):
            order_id += 1
            session_id += 1
            rest = restaurants[int(rng.choice(n_restaurants, p=weights))]
            day = int(rng.integers(0, days))
            hour = int(rng.choice(24, p=hour_weights))
            minute = int(rng.integers(0, 60))
            ts = START + timedelta(days=day, hours=hour, minutes=minute)
            # IP is an access observation, not a persistent identity or proof of co-location.
            ip_group = int(rng.integers(1, 55)) if rng.random() < .14 else int(client['household_id'][1:]) + 100
            sessions.append({'sessao_id': f'S{session_id:07d}', 'cliente_id': client['cliente_id'],
                             'device_id': household_device, 'ip_token': f'IP{ip_group:05d}', 'iniciada_em': iso(ts)})
            amount = round(float(rng.lognormal(np.log(float(rest['preco_base'])) - .5 * .32**2, .32)), 2)
            orders.append({'pedido_id': f'P{order_id:07d}', 'cliente_id': client['cliente_id'],
                           'restaurante_id': rest['restaurante_id'], 'sessao_id': f'S{session_id:07d}',
                           'criado_em': iso(ts), 'valor_bruto': f'{amount:.2f}', 'moeda': 'BRL'})
    tables = {
        'clientes.csv': (clients, ['cliente_id','household_id','region','perfil','data_criacao']),
        'domicilios.csv': (households, ['household_id','region','shared_device_id']),
        'dispositivos.csv': (devices, ['device_id','device_type']),
        'restaurantes.csv': (restaurants, ['restaurante_id','region','categoria','preco_base','popularidade']),
        'sessoes.csv': (sessions, ['sessao_id','cliente_id','device_id','ip_token','iniciada_em']),
        'pedidos.csv': (orders, ['pedido_id','cliente_id','restaurante_id','sessao_id','criado_em','valor_bruto','moeda']),
    }
    checksums = {}
    for filename, (rows, columns) in tables.items():
        path = output / filename
        save_csv(path, rows, columns)
        checksums[filename] = hashlib.sha256(path.read_bytes()).hexdigest()
    manifest = {'project':'NGIF-FRAUD-001', 'sprint':'01', 'seed':seed,
                'parameters': {'n_clients':n_clients,'n_restaurants':n_restaurants,
                               'target_mean_orders_per_client':target_mean,'days':days},
                'counts':{name:len(rows) for name,(rows,_) in tables.items()},
                'sha256':checksums, 'ground_truth_available':False,
                'notes':'All data synthetic; no fraud injected in Sprint 01. Times are UTC.'}
    (output/'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print(json.dumps(manifest['counts'], indent=2))
    return manifest

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, default=Path('data'))
    p.add_argument('--seed', type=int, default=42)
    p.add_argument('--clients', type=int, default=3000)
    p.add_argument('--restaurants', type=int, default=120)
    p.add_argument('--mean-orders', type=float, default=6)
    p.add_argument('--days', type=int, default=90)
    args = p.parse_args()
    if args.clients < 1 or args.restaurants < 1 or args.mean_orders <= 0 or args.days < 1:
        p.error('clients, restaurants, mean-orders and days must be positive')
    generate(args.output, args.seed, args.clients, args.restaurants, args.mean_orders, args.days)
