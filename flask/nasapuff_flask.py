from flask import Flask, render_template
import requests
from apscheduler.schedulers.background import BackgroundScheduler

app = Flask(__name__)
API_KEY = 'O0OVNYOxLO1QIe8eb31Kaf1LYbR6MRtqMNaoFm2f'
current_apod_url = None

def fetch_apod_data(api_key):
    """ Fetch data from NASA's APOD API """
    url = f"https://api.nasa.gov/planetary/apod?api_key={api_key}"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

def update_image():
    global current_apod_url
    apod_data = fetch_apod_data(API_KEY)
    if apod_data['url'] != current_apod_url:
        current_apod_url = apod_data['url']
        print(f"Updated image URL to: {current_apod_url}")
    else:
        print("No update needed. Same image URL.")


@app.route("/")
def home():
    """ Render home page with APOD data """
    apod_data = fetch_apod_data(API_KEY) if current_apod_url is None else {"url": current_apod_url}
    return render_template('index.html', apod=apod_data)

if __name__ == "__main__":
    scheduler = BackgroundScheduler()
    scheduler.add_job(func=update_image, trigger="interval", hours=3)
    scheduler.start()
    app.run(debug=True,use_reloader=False)  # Important: Disable reloader if running with scheduler
