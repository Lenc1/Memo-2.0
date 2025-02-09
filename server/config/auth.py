import jwt
import datetime
from functools import wraps
from flask import request, jsonify

from config import config
from models import db

# 生成 JWT 令牌
def generate_token(username):
    payload = {
        'username': username,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=200)  # 24小时有效期
    }
    return jwt.encode(payload, config.SECRET_KEY, algorithm='HS256')

# 验证JWT的装饰器
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"success": False, "message": "Token is missing"}), 401

        try:
            data = jwt.decode(token, config.SECRET_KEY, algorithms=['HS256'])
            db.cursor.execute("SELECT id FROM users WHERE username=%s", (data['username'],))
            user = db.cursor.fetchone()
            if not user:
                return jsonify({"success": False, "message": "User not found"}), 401
            return f(user_id=user[0], *args, **kwargs)
        except jwt.ExpiredSignatureError:
            return jsonify({"success": False, "message": "Token has expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"success": False, "message": "Invalid token"}), 401

    return decorated
