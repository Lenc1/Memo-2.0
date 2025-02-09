from flask import Flask
from flask_cors import CORS

from config import config
from router import router

app = Flask(__name__)
CORS(app)
app.config['UPLOAD_FOLDER'] = config.UPLOAD_FOLDER

app.register_blueprint(router.bp) # 路由蓝图注册
# 启动 Flask 应用
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)