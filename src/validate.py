"""Integrity and reproducibility manifest verification."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

def read_csv(path):
    with path.open(newline='', encoding='utf-8') as f:
        return list(csv.DictReader(f))

def validate(folder):
    manifest = json.loads((folder/'manifest.json').read_text(encoding='utf-8'))
    data = {}
    for filename, expected in manifest['sha256'].items():
        path = folder/filename
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, f'Hash divergente: {filename}'
        data[filename] = read_csv(path)
        assert len(data[filename]) == manifest['counts'][filename], f'Contagem divergente: {filename}'
    clients = {r['cliente_id'] for r in data['clientes.csv']}
    restaurants = {r['restaurante_id'] for r in data['restaurantes.csv']}
    devices = {r['device_id'] for r in data['dispositivos.csv']}
    sessions = {r['sessao_id']:r for r in data['sessoes.csv']}
    for s in sessions.values():
        assert s['cliente_id'] in clients and s['device_id'] in devices
    for p in data['pedidos.csv']:
        assert p['cliente_id'] in clients and p['restaurante_id'] in restaurants
        assert p['sessao_id'] in sessions
        assert sessions[p['sessao_id']]['cliente_id'] == p['cliente_id']
        assert float(p['valor_bruto']) > 0 and p['moeda'] == 'BRL'
    print('VALIDAÇÃO APROVADA: hashes, contagens, referências e valores.')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', type=Path, default=Path('data'))
    validate(parser.parse_args().data)
