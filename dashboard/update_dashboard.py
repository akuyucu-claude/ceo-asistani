#!/usr/bin/env python3
"""
update_dashboard.py — CEO Asistanı Dashboard Yenileyici

Hermes agent tarafından her saat (veya event'te) çalıştırılır.
Obsidian vault'tan verileri okur, dashboard/index.html'i günceller.

Kullanım:
  python3 update_dashboard.py --vault /opt/ak-yapi/vault --output /var/www/dashboard/index.html
"""

import os
import re
import json
import argparse
from datetime import datetime
from pathlib import Path


def parse_markdown_value(filepath: str, key: str) -> str:
    """Markdown dosyasından key: value formatında değer okur."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        match = re.search(rf'^{key}:\s*(.+)$', content, re.MULTILINE)
        return match.group(1).strip() if match else ''
    except FileNotFoundError:
        return ''


def parse_markdown_list(filepath: str, key: str) -> list:
    """Markdown dosyasından liste okur (key: altındaki - items)."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        # Find the key line, then capture all lines starting with - until next header or empty
        pattern = rf'{key}:\s*\n((?:\s*-.*\n?)*)'
        match = re.search(pattern, content, re.MULTILINE)
        if not match:
            return []
        items = []
        for line in match.group(1).strip().split('\n'):
            line = line.strip()
            if line.startswith('- '):
                items.append(line[2:].strip())
        return items
    except FileNotFoundError:
        return []


def read_vault(vault_path: str) -> dict:
    """Obsidian vault'tan tüm verileri oku."""
    v = Path(vault_path)
    data = {
        'company_name': 'AK Yapı İnşaat',
        'cash_position': {'balance': 0, 'trend': 0, 'accounts': 0},
        'receivables': {'total': 0, 'overdue': 0, 'count': 0, 'overdue_list': []},
        'cashflow': {'net': 0, 'inflow': 0, 'outflow': 0, 'projection': 0},
        'tasks': {'total': 0, 'critical': 0, 'projects': 0},
        'alerts': [],
        'radar': [],
        'chart_data': [],
        'agenda': {
            'date': '', 'meeting_count': 0, 'first_meeting': '',
            'meetings': [],
            'overdue_count': 0, 'today_count': 0, 'week_count': 0,
            'overdue': [], 'today': []
        }
    }

    # Finans verileri
    nakit_path = v / 'finans' / 'nakit-pozisyonu.md'
    if nakit_path.exists():
        bakiye = parse_markdown_value(str(nakit_path), 'bakiye')
        if bakiye:
            data['cash_position']['balance'] = int(re.sub(r'[^0-9]', '', bakiye))
        trend = parse_markdown_value(str(nakit_path), 'trend')
        if trend:
            data['cash_position']['trend'] = int(re.sub(r'[^0-9-]', '', trend))
        hesap = parse_markdown_value(str(nakit_path), 'hesap_sayisi')
        if hesap:
            data['cash_position']['accounts'] = int(hesap)

    tahsilat_path = v / 'finans' / 'tahsilat.md'
    if tahsilat_path.exists():
        toplam = parse_markdown_value(str(tahsilat_path), 'toplam')
        if toplam:
            data['receivables']['total'] = int(re.sub(r'[^0-9]', '', toplam))
        gecikmis = parse_markdown_value(str(tahsilat_path), 'gecikmis_sayisi')
        if gecikmis:
            data['receivables']['overdue'] = int(gecikmis)
        acik = parse_markdown_value(str(tahsilat_path), 'acik_fatura')
        if acik:
            data['receivables']['count'] = int(acik)
        data['receivables']['overdue_list'] = parse_markdown_list(str(tahsilat_path), 'gecikmis_listesi')

    nakit_akis_path = v / 'finans' / 'nakit-akisi.md'
    if nakit_akis_path.exists():
        net = parse_markdown_value(str(nakit_akis_path), 'net')
        if net:
            data['cashflow']['net'] = int(re.sub(r'[^0-9-]', '', net))
        giris = parse_markdown_value(str(nakit_akis_path), 'giris')
        if giris:
            data['cashflow']['inflow'] = int(re.sub(r'[^0-9]', '', giris))
        cikis = parse_markdown_value(str(nakit_akis_path), 'cikis')
        if cikis:
            data['cashflow']['outflow'] = int(re.sub(r'[^0-9]', '', cikis))
        proj = parse_markdown_value(str(nakit_akis_path), 'projeksiyon')
        if proj:
            data['cashflow']['projection'] = int(re.sub(r'[^0-9-]', '', proj))

    # Projeler
    isler_path = v / 'projeler' / 'acik-isler.md'
    if isler_path.exists():
        toplam = parse_markdown_value(str(isler_path), 'toplam')
        if toplam:
            data['tasks']['total'] = int(toplam)
        kritik = parse_markdown_value(str(isler_path), 'kritik')
        if kritik:
            data['tasks']['critical'] = int(kritik)
        proje = parse_markdown_value(str(isler_path), 'aktif_proje')
        if proje:
            data['tasks']['projects'] = int(proje)

    # Alert'ler
    alert_path = v / 'raporlar' / 'alertler.md'
    if alert_path.exists():
        data['alerts'] = parse_markdown_list(str(alert_path), 'aktif')

    # Sektör radarı
    radar_path = v / 'raporlar' / 'sektor-radari.md'
    if radar_path.exists():
        data['radar'] = parse_markdown_list(str(radar_path), 'items')

    # Chart verisi
    chart_path = v / 'finans' / 'nakit-grafik.md'
    if chart_path.exists():
        data['chart_data'] = parse_markdown_list(str(chart_path), 'veri')

    # Gündem
    gundem_path = v / 'gundem' / 'bugun.md'
    if gundem_path.exists():
        data['agenda']['date'] = parse_markdown_value(str(gundem_path), 'tarih')
        mc = parse_markdown_value(str(gundem_path), 'toplanti_sayisi')
        data['agenda']['meeting_count'] = int(mc) if mc else 0
        data['agenda']['first_meeting'] = parse_markdown_value(str(gundem_path), 'erken_toplanti')
        data['agenda']['meetings'] = parse_markdown_list(str(gundem_path), 'Toplantılar')

    # Aksiyonlar
    aksiyon_path = v / 'gundem' / 'aksiyonlar.md'
    if aksiyon_path.exists():
        gs = parse_markdown_value(str(aksiyon_path), 'gecikmis_sayisi')
        data['agenda']['overdue_count'] = int(gs) if gs else 0
        bs = parse_markdown_value(str(aksiyon_path), 'bugun_sayisi')
        data['agenda']['today_count'] = int(bs) if bs else 0
        hs = parse_markdown_value(str(aksiyon_path), 'bu_hafta_sayisi')
        data['agenda']['week_count'] = int(hs) if hs else 0
        data['agenda']['overdue'] = parse_markdown_list(str(aksiyon_path), 'Gecikmiş')
        data['agenda']['today'] = parse_markdown_list(str(aksiyon_path), 'Bugün')

    # Şirket adı
    sirket_path = v / 'sirket.md'
    if sirket_path.exists():
        name = parse_markdown_value(str(sirket_path), 'ad')
        if name:
            data['company_name'] = name

    return data


def format_tl(value: int) -> str:
    """TL formatı: 2847000 → ₺2.847.000"""
    if value < 0:
        return '-₺' + f'{abs(value):,}'.replace(',', '.')
    return '₺' + f'{value:,}'.replace(',', '.')


def generate_html(data: dict, template_path: str) -> str:
    """Dashboard HTML'ini güncelle."""
    with open(template_path, 'r', encoding='utf-8') as f:
        html = f.read()

    now = datetime.now()
    months_tr = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
                 'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık']
    days_tr = ['Pazar','Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi']

    # Company name
    html = html.replace('AK Yapı İnşaat</h1>', f'{data["company_name"]}</h1>')

    # Cash position
    b = data['cash_position']
    trend_class = 'up' if b['trend'] >= 0 else 'down'
    trend_arrow = '↗' if b['trend'] >= 0 else '↘'
    html = html.replace('id="cash">₺2.847.000<', f'id="cash">{format_tl(b["balance"])}<')
    html = re.sub(r'<div class="trend up">↗ %12 aylık<', 
                  f'<div class="trend {trend_class}">{trend_arrow} %{abs(b["trend"])} aylık<', html)
    html = re.sub(r'3 banka hesabı toplamı', f'{b["accounts"]} banka hesabı toplamı', html)

    # Receivables
    r = data['receivables']
    html = html.replace('id="receivables">₺1.230.000<', f'id="receivables">{format_tl(r["total"])}<')
    html = re.sub(r'⚠ 7 fatura gecikmiş', f'⚠ {r["overdue"]} fatura gecikmiş', html)
    html = re.sub(r'Toplam 23 açık fatura', f'Toplam {r["count"]} açık fatura', html)

    # Cashflow
    cf = data['cashflow']
    cf_class = 'up' if cf['net'] >= 0 else 'down'
    cf_arrow = '↗' if cf['net'] >= 0 else '↘'
    html = html.replace('id="cashflow">+₺412.000<', f'id="cashflow">{format_tl(cf["net"])}<')
    html = re.sub(r'<div class="trend up">↗ projeksiyon \+₺680K<', 
                  f'<div class="trend {cf_class}">{cf_arrow} projeksiyon {format_tl(cf["projection"])}<', html)
    html = re.sub(r'Giriş ₺1.84M / Çıkış ₺1.43M', 
                  f'Giriş {format_tl(cf["inflow"])} / Çıkış {format_tl(cf["outflow"])}', html)

    # Tasks
    t = data['tasks']
    html = html.replace('id="tasks">27<', f'id="tasks">{t["total"]}<')
    html = re.sub(r'14 kritik', f'{t["critical"]} kritik', html)
    html = re.sub(r'6 proje aktif', f'{t["projects"]} proje aktif', html)

    # Alerts
    if data['alerts']:
        alerts_html = ''
        for alert in data['alerts']:
            # Parse "TAHSILAT: XYZ İnşaat — 620.000 TL, 12 gün gecikti"
            parts = alert.split(':', 1)
            badge_type = 'critical' if parts[0].strip() in ['TAHSILAT', 'TEDARIK'] else 'warning'
            alerts_html += f'''      <div class="alert-item">
        <span class="alert-badge {badge_type}">{parts[0].strip()}</span>
        {parts[1].strip() if len(parts) > 1 else alert}
      </div>\n'''
        html = re.sub(r'<div id="alerts-list">.*?</div>\s*</div>\s*<!-- BOTTOM', 
                      f'<div id="alerts-list">\n{alerts_html}    </div>\n  </div>\n\n  <!-- BOTTOM', 
                      html, flags=re.DOTALL)

    # Radar
    if data['radar']:
        radar_html = ''
        icons = ['📊', '🏗', '🏢', '📋', '💰', '🔔', '📈', '🌍']
        icon_classes = ['price', 'tender', 'competitor', 'price', 'price', 'tender', 'price', 'price']
        for i, item in enumerate(data['radar'][:5]):
            parts = item.split(': ', 1)
            title = parts[0]
            desc = parts[1] if len(parts) > 1 else ''
            idx = i % len(icons)
            radar_html += f'''        <div class="radar-item">
          <div class="radar-icon {icon_classes[idx]}">{icons[idx]}</div>
          <div class="radar-body">
            <div class="title">{title}</div>
            <div class="desc">{desc}</div>
          </div>
        </div>\n'''
        html = re.sub(r'<div id="radar-list">.*?</div>\s*</div>\s*</div>\s*<!-- FOOTER',
                      f'<div id="radar-list">\n{radar_html}        </div>\n      </div>\n  </div>\n\n  <!-- FOOTER',
                      html, flags=re.DOTALL)

    # Gündem + Aksiyon
    agenda = data['agenda']
    # Meeting count
    html = re.sub(r'id="meeting-count">.*?</span>', f'id="meeting-count">{agenda["meeting_count"]} toplantı</span>', html)
    html = re.sub(r'id="first-meeting">.*?</strong>', f'id="first-meeting">{agenda["first_meeting"]}</strong>', html)
    # Agenda date
    months_tr_agenda = {'2026-05-18': '18 Mayıs', '2026-05-19': '19 Mayıs'}
    agenda_date = months_tr_agenda.get(agenda['date'], agenda['date'] if agenda['date'] else 'Bugün')
    html = re.sub(r'id="agenda-date">.*?</span>', f'id="agenda-date">{agenda_date}</span>', html)

    # Meetings list
    if agenda['meetings']:
        meetings_html = ''
        for m in agenda['meetings']:
            # Format: "09:30 | İcra Kurulu | CFO, COO | Bütçe revizyonu | hazir"
            parts = [p.strip() for p in m.split('|')]
            if len(parts) >= 4:
                time = parts[0]
                title = parts[1]
                people = parts[2]
                topic = parts[3]
                status = parts[4] if len(parts) > 4 else 'hazir'
                is_ready = status == 'hazir'
                meetings_html += f'''        <div class="meeting-item {'ready' if is_ready else 'missing'}">
          <div class="meeting-time">{time}</div>
          <div class="meeting-body">
            <div class="meeting-title">{title}</div>
            <div class="meeting-detail">👥 {people}</div>
            <div class="meeting-detail">📋 {topic}</div>
          </div>
          <div class="meeting-badge {'ok' if is_ready else 'warn'}">{'✓ Hazır' if is_ready else '⚡ Eksik hazırlık'}</div>
        </div>\n'''
        html = re.sub(r'<div id="meetings-list">.*?</div>\s*</div>\s*<!-- AKSIYON',
                      f'<div id="meetings-list">\n{meetings_html}      </div>\n    </div>\n\n    <!-- AKSIYON',
                      html, flags=re.DOTALL)

    # Action counts
    html = re.sub(r'id="overdue-count">.*?</strong>', f'id="overdue-count">{agenda["overdue_count"]}</strong>', html)
    html = re.sub(r'id="today-count">.*?</strong>', f'id="today-count">{agenda["today_count"]}</strong>', html)
    html = re.sub(r'id="week-count">.*?</strong>', f'id="week-count">{agenda["week_count"]}</strong>', html)

    # Action items - overdue
    if agenda['overdue']:
        overdue_html = '\n'.join([
            f'          <div class="action-item"><span class="action-dot critical"></span>{item}</div>'
            for item in agenda['overdue']
        ])
        html = re.sub(r'(<div class="action-section-title critical">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>)',
                      f'<div class="action-section-title critical">🔴 Gecikmiş</div>\n{overdue_html}',
                      html, flags=re.DOTALL)

    # Action items - today
    if agenda['today']:
        today_html = '\n'.join([
            f'          <div class="action-item"><span class="action-dot today"></span>{item}</div>'
            for item in agenda['today']
        ])
        html = re.sub(r'(<div class="action-section-title today">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>\s*<div class="action-item">.*?</div>)',
                      f'<div class="action-section-title today">🟡 Bugün</div>\n{today_html}',
                      html, flags=re.DOTALL)

    # Date
    date_str = f'{now.day} {months_tr[now.month-1]} {now.year}, {days_tr[now.weekday()]}'
    html = re.sub(r'id="date">.*?</span>', f'id="date">{date_str}</span>', html)

    # Updated
    updated_str = f'Son güncelleme: {now.day} {months_tr[now.month-1]} {now.year} {now.strftime("%H:%M")}'
    html = re.sub(r'id="updated">.*?</span>', f'id="updated">{updated_str}</span>', html)

    # Chart data
    if data['chart_data']:
        chart_vals = [int(x.strip()) for x in data['chart_data'] if x.strip().isdigit()]
        if chart_vals:
            js_data = json.dumps(chart_vals)
            html = html.replace(
                'const chartData = [2100,1950,2200,2400,2600,2350,2500,2700,2550,2400,2650,2850,2750,2600,2500,2680,2900,3100,2950,2800,2700,2850,3050,3200,3000,2950,3100,3300,3150,2847]',
                f'const chartData = {js_data}'
            )

    return html


def main():
    parser = argparse.ArgumentParser(description='CEO Asistanı Dashboard yenileyici')
    parser.add_argument('--vault', default='/opt/ceo-asistani/vault', help='Obsidian vault yolu')
    parser.add_argument('--output', default='/var/www/dashboard/index.html', help='Çıktı HTML yolu')
    parser.add_argument('--template', default=None, help='Dashboard şablonu (varsayılan: kendi içindeki)')
    args = parser.parse_args()

    # Template path
    if args.template:
        template_path = args.template
    else:
        # Default: same directory as this script
        script_dir = Path(__file__).parent
        template_path = script_dir / 'index.html'
        # If index.html is the output itself, use the output as template
        if str(template_path) == args.output:
            template_path = args.output  # Read from existing

    if not Path(template_path).exists():
        print(f'HATA: Dashboard şablonu bulunamadı: {template_path}')
        return 1

    # Read vault
    data = read_vault(args.vault)

    # Generate HTML
    html = generate_html(data, str(template_path))

    # Write output
    os.makedirs(Path(args.output).parent, exist_ok=True)
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(html)

    print(f'✓ Dashboard güncellendi: {args.output}')
    print(f'  Şirket: {data["company_name"]}')
    print(f'  Nakit: {format_tl(data["cash_position"]["balance"])}')
    print(f'  Tahsilat: {format_tl(data["receivables"]["total"])}')
    print(f'  Zaman: {datetime.now().strftime("%d.%m.%Y %H:%M")}')
    return 0


if __name__ == '__main__':
    exit(main())
