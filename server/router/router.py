import os

from flask import request, jsonify, Blueprint
import mysql.connector
from werkzeug.utils import secure_filename
from utils import utils
from config import auth,config
from models import db

bp = Blueprint('api', __name__)

cursor = db.cursor

#登录
@bp.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    if not username or not password:
        return jsonify({"success": False, "message": "用户名和密码不能为空"}), 400

    # 查询用户
    cursor.execute("SELECT password FROM users WHERE username=%s", (username,))
    user = cursor.fetchone()

    if user and user[0] == utils.hash(password):
        # 生成 JWT 令牌
        token = auth.generate_token(username)
        return jsonify({"success": True, "message": "登录成功！", "token": token}), 200
    else:
        # 登录失败
        return jsonify({"success": False, "message": "用户名或密码错误"}), 401

#注册
@bp.route('/api/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    nickname = '爱吃泡面用户001'
    email = data.get('email')

    if not username or not password:
        return jsonify({"success": False, "message": "用户名和密码不能为空"}), 400
    hashed_password = utils.hash(password)

    try:
        # 插入新用户数据
        cursor.execute(
            "INSERT INTO users (username, password, email, nickname) VALUES (%s, %s, %s, %s)",
            (username, hashed_password, email, nickname)
        )
        db.conn.commit()

        # 获取新插入用户的ID
        user_id = cursor.lastrowid
        print(user_id,username,password)
        # 在积分表中创建对应的记录
        cursor.execute(
            "INSERT INTO point (id, point) VALUES (%s, %s)",
            (user_id, 0)
        )
        db.conn.commit()

        # 在机会表中创建对应的记录
        cursor.execute(
            "INSERT INTO chance (id, chance) VALUES (%s, 3)",
            (user_id,)
        )
        db.conn.commit()
        return jsonify({"success": True, "message": "注册成功"}), 201
    except mysql.connector.IntegrityError:
        return jsonify({"success": False, "message": "用户名已存在"}), 409

#上传头像
@bp.route('/api/upload_avatar', methods=['POST'])
@auth.token_required
def upload_avatar(user_id):
    if 'avatar' not in request.files:
        return jsonify({"success": False, "message": "没有找到文件"}), 400

    file = request.files['avatar']

    if file and utils.allowed_file(file.filename):
        filename = secure_filename(file.filename)
        file_path = os.path.join(bp.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        # 构建完整的头像URL
        server_url = ""  # 修改为你的服务器地址
        avatar_url = f"{server_url}/{config.UPLOAD_FOLDER}{filename}"

        # 更新数据库中的头像URL
        cursor.execute("UPDATE users SET avatar = %s WHERE id = %s", (avatar_url, user_id))
        db.conn.commit()

        return jsonify({"success": True, "avatarUrl": avatar_url}), 200
    else:
        return jsonify({"success": False, "message": "文件类型不允许"}), 400
#获取用户名
@bp.route('/api/get_username', methods=['GET'])
@auth.token_required
def get_username(user_id):
    cursor.execute("SELECT username FROM users WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        return jsonify({"username": result[0]})
    else:
        return jsonify({"message": "User not found"}), 404
#获取用户昵称
@bp.route('/api/get_nickname', methods=['GET'])
@auth.token_required
def get_nickname(user_id):
    cursor.execute("SELECT nickname FROM users WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        return jsonify({"nickname": result[0]})
    else:
        return jsonify({"message": "Nickname not found"}), 404
#修改昵称路由
@bp.route('/api/update_nickname', methods=['PUT'])
@auth.token_required
def update_nickname(user_id):
    data = request.json
    new_nickname = data.get('nickname')

    if not new_nickname:
        return jsonify({"success": False, "message": "新昵称不能为空"}), 400

    cursor.execute("UPDATE users SET nickname = %s WHERE id = %s", (new_nickname, user_id))
    db.conn.commit()

    return jsonify({"success": True, "message": "昵称更新成功"}), 200
# 获取个性签名路由
@bp.route('/api/get_signature', methods=['GET'])
@auth.token_required
def get_signature(user_id):
    cursor.execute("SELECT signature FROM users WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        return jsonify({'signature': result[0]})
    else:
        return jsonify({'message': 'Signature not found'}, 404)
# 修改个性签名路由
@bp.route('/api/update_signature', methods=['PUT'])
@auth.token_required
def update_signature(user_id):
    data = request.json
    new_signature = data.get('signature')

    if not new_signature:
        return jsonify({"success": False, "message": "新个性签名不能为空"}), 400

    cursor.execute("UPDATE users SET signature = %s WHERE id = %s", (new_signature, user_id))
    db.conn.commit()

    return jsonify({"success": True, "message": "个性签名更新成功"}), 200
# 获取当前用户的剩余答题机会
@bp.route('/api/get_remaining_chances', methods=['GET'])
@auth.token_required
def get_remaining_chances(user_id):
    cursor.execute("SELECT chance FROM chance WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        return jsonify({'remaining_chances': result[0]})
    else:
        return jsonify({'remaining_chances': 0})

# 提交答案后减少一次答题机会
@bp.route('/api/reduce_chance', methods=['POST'])
@auth.token_required
def reduce_chance(user_id):
    cursor.execute("SELECT chance FROM chance WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result and result[0] > 0:
        cursor.execute("UPDATE chance SET chance = chance - 1 WHERE id = %s", (user_id,))
        db.conn.commit()
        return jsonify({'message': '机会已减少'})
    else:
        return jsonify({'message': '没有剩余机会'}, 400)
#增加分数
@bp.route('/api/add_score', methods=['POST'])
@auth.token_required
def add_score(user_id):
    data = request.json
    score_to_add = data.get('score')

    if score_to_add is None:
        return jsonify({'message': 'Score value is missing'}), 400

    cursor.execute("SELECT point FROM point WHERE id = %s", (user_id,))
    current_score = cursor.fetchone()

    if current_score:
        new_score = current_score[0] + score_to_add
        cursor.execute("UPDATE point SET point = %s WHERE id = %s", (new_score, user_id))
        db.conn.commit()
        return jsonify({'message': 'Score added successfully'})
    else:
        return jsonify({'message': 'User not found for adding score'}), 404
#获取用户信息
@bp.route('/api/get_user_info', methods=['GET'])
@auth.token_required
def get_user_info(user_id):
    cursor.execute("SELECT nickname, signature, gender, avatar FROM users WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        server_url = "http://192.168.101.38:5000"  # 修改为你的服务器地址
        avatar_path = result[3]

        # 如果 avatar 字段没有包含服务器 URL，则手动添加
        if avatar_path and not avatar_path.startswith("http"):
            avatar_path = f"{server_url}{avatar_path}"

        return jsonify({
            'nickname': result[0],
            'signature': result[1],
            'gender': result[2],
            'avatar': avatar_path
        })
    else:
        return jsonify({'message': 'User not found'}), 404

# 更新用户信息
@bp.route('/api/update_user_info', methods=['PUT'])
@auth.token_required
def update_user_info(user_id):
    data = request.json
    new_nickname = data.get('nickname')
    new_signature = data.get('signature')
    new_gender = data.get('gender')

    if not new_nickname or not new_signature or not new_gender:
        return jsonify({"success": False, "message": "所有字段均不能为空"}), 400

    cursor.execute(
        "UPDATE users SET nickname = %s, signature = %s, gender = %s WHERE id = %s",
        (new_nickname, new_signature, new_gender, user_id)
    )
    db.conn.commit()

    return jsonify({"success": True, "message": "用户信息更新成功"}), 200
# 获取分数
@bp.route('/api/get_score', methods=['GET'])
@auth.token_required
def get_score(user_id):
    cursor.execute("SELECT point FROM point WHERE id = %s", (user_id,))
    result = cursor.fetchone()
    if result:
        return jsonify({'score': result[0]})
    else:
        return jsonify({'score': 0})

