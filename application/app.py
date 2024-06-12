import os
from flask import Flask, request, send_file, send_from_directory, after_this_request
from gtts import gTTS
from tempfile import NamedTemporaryFile

app = Flask(__name__)


@app.route('/')
def index():
    return send_from_directory('static', 'index.html')


@app.route('/api/text-to-speech', methods=['POST'])
def text_to_speech():
    text = request.json.get('text', '')
    if not text:
        return "No text provided", 400

    lang = request.json.get('lang', 'pl')
    tts = gTTS(text=text, lang=lang, slow=False)
    temp_file = NamedTemporaryFile(delete=False, suffix='.mp3')
    tts.save(temp_file.name)

    @after_this_request
    def remove_file(response):
        os.remove(temp_file.name)
        return response

    return send_file(temp_file.name, as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
