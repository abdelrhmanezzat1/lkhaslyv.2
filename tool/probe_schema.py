import urllib.request

base = 'https://uewkpfwrmmpklpleqltg.supabase.co/rest/v1/'
key = 'sb_publishable_ga6Aa3lhKff72zFzTZxvpQ_hq0nOLBV'

tables = [
    # Known-existing tables (control group to validate the probe method)
    'cars', 'orders', 'profiles',
    # Candidate lookup/catalog tables
    'car_models', 'brands', 'car_brands', 'vehicle_models',
    'car_model_catalog', 'mechanical_issues', 'car_makes',
    'makes', 'car_types', 'models', 'car_model', 'car_brand',
]

for t in tables:
    try:
        req = urllib.request.Request(
            base + t + '?select=*&limit=1',
            headers={'apikey': key, 'Authorization': 'Bearer ' + key},
        )
        r = urllib.request.urlopen(req, timeout=10)
        body = r.read().decode('utf-8')
        print(t + ': HTTP ' + str(r.status) + ' body=' + body[:120])
    except urllib.error.HTTPError as e:
        print(t + ': HTTP ' + str(e.code))
    except Exception as e:
        print(t + ': ' + type(e).__name__ + ' ' + str(e))