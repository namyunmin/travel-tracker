#!/usr/bin/env python3
"""
Python 환경 호환성 검사 스크립트
"""

import sys
import subprocess
import pkg_resources

def check_python_version():
    """Python 버전 확인"""
    version = sys.version_info
    print(f"Python 버전: {version.major}.{version.minor}.{version.micro}")
    
    if version.major == 3 and version.minor >= 11:
        print("✅ Python 버전 호환")
        return True
    else:
        print("❌ Python 3.11+ 필요")
        return False

def check_packages():
    """설치된 패키지 확인"""
    required_packages = {
        'Flask': '>=2.3.0',
        'Flask-CORS': '>=4.0.0',
        'Werkzeug': '>=2.3.0'
    }
    
    print("\n패키지 확인:")
    all_good = True
    
    for package, version_req in required_packages.items():
        try:
            pkg = pkg_resources.get_distribution(package)
            print(f"✅ {package}: {pkg.version}")
        except pkg_resources.DistributionNotFound:
            print(f"❌ {package}: 설치되지 않음")
            all_good = False
        except Exception as e:
            print(f"❌ {package}: {e}")
            all_good = False
    
    return all_good

def fix_suggestions():
    """수정 제안"""
    print("\n🔧 문제 해결 방법:")
    print("1. Python 3.11 사용 (권장):")
    print("   python3.11 -m venv venv")
    print("   venv\\Scripts\\activate")
    print("   pip install -r requirements.txt")
    print()
    print("2. Python 3.12 호환 패키지 사용:")
    print("   fix_python312.bat 실행")
    print()
    print("3. 개발 모드로 실행:")
    print("   python main.py")

if __name__ == "__main__":
    print("🔍 Python 환경 검사 시작...\n")
    
    python_ok = check_python_version()
    packages_ok = check_packages()
    
    if python_ok and packages_ok:
        print("\n🎉 모든 검사 통과! 서버를 시작할 수 있습니다.")
        print("python main.py 명령으로 서버를 시작하세요.")
    else:
        fix_suggestions()
