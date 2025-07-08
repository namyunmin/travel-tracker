#!/usr/bin/env python3
"""
지도 기반 실시간 위치 추적 앱 - 여행 경로 추적기
"""

from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_cors import CORS
import sqlite3
import json
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)  # 개발 중 CORS 이슈 해결

# 현재 스크립트의 디렉토리 기준으로 경로 설정
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FRONTEND_DIR = os.path.join(BASE_DIR, 'frontend')
DB_PATH = os.path.join(BASE_DIR, 'location_data.db')

# 데이터베이스 초기화
def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # 위치 데이터 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            address TEXT
        )
    ''')
    
    # 마커/장소 데이터 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS markers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            description TEXT,
            category TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # 여행 경로 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS travel_routes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            route_name TEXT NOT NULL,
            description TEXT,
            color TEXT DEFAULT '#FF0000',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            is_active BOOLEAN DEFAULT FALSE
        )
    ''')
    
    # 경로 포인트 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS route_points (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            route_id INTEGER NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            accuracy REAL,
            FOREIGN KEY (route_id) REFERENCES travel_routes (id)
        )
    ''')
    
    conn.commit()
    conn.close()

# 위치 데이터 저장
@app.route('/api/save-location', methods=['POST'])
def save_location():
    try:
        data = request.get_json()
        user_id = data.get('user_id', 'anonymous')
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        address = data.get('address', '')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO locations (user_id, latitude, longitude, address)
            VALUES (?, ?, ?, ?)
        ''', (user_id, latitude, longitude, address))
        
        conn.commit()
        conn.close()
        
        return jsonify({'status': 'success', 'message': '위치가 저장되었습니다.'})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 새 여행 경로 시작
@app.route('/api/start-route', methods=['POST'])
def start_route():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        route_name = data.get('route_name', f'여행 {datetime.now().strftime("%Y-%m-%d %H:%M")}')
        description = data.get('description', '')
        color = data.get('color', '#FF0000')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # 기존 활성 경로 비활성화
        cursor.execute('''
            UPDATE travel_routes SET is_active = FALSE WHERE user_id = ?
        ''', (user_id,))
        
        # 새 경로 생성
        cursor.execute('''
            INSERT INTO travel_routes (user_id, route_name, description, color, is_active)
            VALUES (?, ?, ?, ?, TRUE)
        ''', (user_id, route_name, description, color))
        
        route_id = cursor.lastrowid
        
        conn.commit()
        conn.close()
        
        return jsonify({
            'status': 'success', 
            'message': '새 여행 경로가 시작되었습니다.',
            'route_id': route_id
        })
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 경로에 포인트 추가
@app.route('/api/add-route-point', methods=['POST'])
def add_route_point():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        accuracy = data.get('accuracy')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # 활성 경로 ID 찾기
        cursor.execute('''
            SELECT id FROM travel_routes 
            WHERE user_id = ? AND is_active = TRUE 
            ORDER BY created_at DESC LIMIT 1
        ''', (user_id,))
        
        result = cursor.fetchone()
        if not result:
            conn.close()
            return jsonify({'status': 'error', 'message': '활성된 경로가 없습니다.'})
        
        route_id = result[0]
        
        # 경로 포인트 추가
        cursor.execute('''
            INSERT INTO route_points (route_id, latitude, longitude, accuracy)
            VALUES (?, ?, ?, ?)
        ''', (route_id, latitude, longitude, accuracy))
        
        conn.commit()
        conn.close()
        
        return jsonify({'status': 'success', 'message': '경로 포인트가 추가되었습니다.'})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 현재 활성 경로 중지
@app.route('/api/stop-route', methods=['POST'])
def stop_route():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            UPDATE travel_routes SET is_active = FALSE WHERE user_id = ? AND is_active = TRUE
        ''', (user_id,))
        
        conn.commit()
        conn.close()
        
        return jsonify({'status': 'success', 'message': '경로 추적이 중지되었습니다.'})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 저장된 경로 목록 조회
@app.route('/api/get-routes', methods=['GET'])
def get_routes():
    try:
        user_id = request.args.get('user_id')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, route_name, description, color, created_at, is_active
            FROM travel_routes
            WHERE user_id = ?
            ORDER BY created_at DESC
        ''', (user_id,))
        
        routes = []
        for row in cursor.fetchall():
            routes.append({
                'id': row[0],
                'route_name': row[1],
                'description': row[2],
                'color': row[3],
                'created_at': row[4],
                'is_active': bool(row[5])
            })
        
        conn.close()
        
        return jsonify({'status': 'success', 'routes': routes})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 특정 경로의 포인트들 조회
@app.route('/api/get-route-points', methods=['GET'])
def get_route_points():
    try:
        route_id = request.args.get('route_id')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # 경로 정보 가져오기
        cursor.execute('''
            SELECT route_name, description, color FROM travel_routes WHERE id = ?
        ''', (route_id,))
        
        route_info = cursor.fetchone()
        if not route_info:
            conn.close()
            return jsonify({'status': 'error', 'message': '경로를 찾을 수 없습니다.'})
        
        # 경로 포인트들 가져오기
        cursor.execute('''
            SELECT latitude, longitude, timestamp, accuracy
            FROM route_points
            WHERE route_id = ?
            ORDER BY timestamp ASC
        ''', (route_id,))
        
        points = []
        for row in cursor.fetchall():
            points.append({
                'latitude': row[0],
                'longitude': row[1],
                'timestamp': row[2],
                'accuracy': row[3]
            })
        
        conn.close()
        
        return jsonify({
            'status': 'success',
            'route_info': {
                'name': route_info[0],
                'description': route_info[1],
                'color': route_info[2]
            },
            'points': points
        })
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 저장된 위치 데이터 조회
@app.route('/api/get-locations', methods=['GET'])
def get_locations():
    try:
        user_id = request.args.get('user_id', 'anonymous')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT latitude, longitude, timestamp, address
            FROM locations
            WHERE user_id = ?
            ORDER BY timestamp DESC
            LIMIT 100
        ''', (user_id,))
        
        locations = []
        for row in cursor.fetchall():
            locations.append({
                'latitude': row[0],
                'longitude': row[1],
                'timestamp': row[2],
                'address': row[3]
            })
        
        conn.close()
        
        return jsonify({'status': 'success', 'locations': locations})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 마커 추가
@app.route('/api/add-marker', methods=['POST'])
def add_marker():
    try:
        data = request.get_json()
        name = data.get('name')
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        description = data.get('description', '')
        category = data.get('category', 'general')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO markers (name, latitude, longitude, description, category)
            VALUES (?, ?, ?, ?, ?)
        ''', (name, latitude, longitude, description, category))
        
        conn.commit()
        conn.close()
        
        return jsonify({'status': 'success', 'message': '마커가 추가되었습니다.'})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 마커 조회
@app.route('/api/get-markers', methods=['GET'])
def get_markers():
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, name, latitude, longitude, description, category, created_at
            FROM markers
            ORDER BY created_at DESC
        ''')
        
        markers = []
        for row in cursor.fetchall():
            markers.append({
                'id': row[0],
                'name': row[1],
                'latitude': row[2],
                'longitude': row[3],
                'description': row[4],
                'category': row[5],
                'created_at': row[6]
            })
        
        conn.close()
        
        return jsonify({'status': 'success', 'markers': markers})
    
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# 헬스 체크 엔드포인트
@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

# 정적 파일 서빙
@app.route('/')
def index():
    try:
        index_path = os.path.join(FRONTEND_DIR, 'index.html')
        if os.path.exists(index_path):
            return send_from_directory(FRONTEND_DIR, 'index.html')
        else:
            return f"Frontend files not found at {FRONTEND_DIR}. Please check the frontend directory."
    except Exception as e:
        return f"Error serving index.html: {str(e)}"

@app.route('/<path:path>')
def static_files(path):
    try:
        file_path = os.path.join(FRONTEND_DIR, path)
        if os.path.exists(file_path):
            return send_from_directory(FRONTEND_DIR, path)
        else:
            return f"File {path} not found", 404
    except Exception as e:
        return f"Error serving {path}: {str(e)}", 404

if __name__ == '__main__':
    # 데이터베이스 초기화
    init_db()
    
    # 개발 서버 실행
    print("\n" + "="*50)
    print("🌍 여행 경로 추적기 서버 시작")
    print("="*50)
    print("📱 접속 주소:")
    print("   - http://localhost:5000")
    print("   - http://0.0.0.0:5000")
    print("="*50)
    
    app.run(debug=True, host='0.0.0.0', port=5000)