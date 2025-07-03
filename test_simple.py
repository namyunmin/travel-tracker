from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "<h1>Hello! Flask 서버가 작동 중입니다!</h1>"

if __name__ == '__main__':
    print("🚀 간단한 Flask 서버 시작...")
    app.run(debug=True, host='0.0.0.0', port=5000)
