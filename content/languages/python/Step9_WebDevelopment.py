# Python 웹 개발 (Flask/Django)
# Flask 또는 Django를 이용한 웹 애플리케이션 개발 기초

# 나쁜 예시: 웹 서버 없이 CGI 스크립트만으로 웹을 구성하거나, 보안 취약점에 대한 고려 없이 개발.
# 좋은 예시: Flask나 Django와 같은 웹 프레임워크를 사용하여 MVC/MTV 패턴 기반으로 구조화되고 안전한 웹 애플리케이션을 개발.

# --- Flask 예시 ---
# Flask는 마이크로 프레임워크로, 가볍고 유연합니다.
# 설치: pip install Flask

from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# 라우트 정의 (URL과 함수 연결)
@app.route('/')
def index():
    """메인 페이지."""
    return "<h1>안녕하세요, Flask!</h1><p>환영합니다.</p><p><a href='/hello/world'>인사하기</a></p>"

@app.route('/hello/<name>')
def hello(name):
    """이름을 받아 인사하는 페이지."""
    return f"<h1>Hello, {name}!</h1>"

@app.route('/user/<username>')
def show_user_profile(username):
    """사용자 프로필 페이지 (템플릿 예시)."""
    # 실제 프로젝트에서는 templates 폴더에 HTML 파일을 만듭니다.
    # 예: templates/user_profile.html
    # return render_template('user_profile.html', username=username)
    return f"사용자 프로필: {username}"


# GET/POST 메서드 처리 예시
@app.route('/login', methods=['GET', 'POST'])
def login():
    """로그인 페이지."""
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        # 실제로는 데이터베이스와 비교하여 로그인 처리
        if username == 'admin' and password == 'password':
            return redirect(url_for('dashboard')) # 로그인 성공 시 대시보드로 리다이렉트
        else:
            return "로그인 실패: 사용자 이름 또는 비밀번호가 잘못되었습니다."
    return '''
        <form action="" method="post">
            <p><input type=text name=username placeholder="사용자 이름"></p>
            <p><input type=password name=password placeholder="비밀번호"></p>
            <p><input type=submit value=Login></p>
        </form>
    '''

@app.route('/dashboard')
def dashboard():
    """대시보드 페이지 (로그인 성공 시 접근)."""
    return "<h1>대시보드</h1><p>환영합니다, 로그인 성공!</p>"

# 이 스크립트를 직접 실행할 때만 Flask 앱을 실행
if __name__ == '__main__':
    # 디버그 모드 활성화 (개발 시 유용, 운영 시에는 비활성화)
    app.run(debug=True)
    # 터미널에서 'flask run' 명령으로 실행할 수도 있습니다.

# --- Django 예시 (참고) ---
# Django는 풀스택 프레임워크로, ORM, 관리자 패널 등 다양한 기능 제공.
# 설치: pip install Django
# 프로젝트 생성: django-admin startproject myproject .
# 앱 생성: python manage.py startapp myapp
# 서버 실행: python manage.py runserver

# Django 코드는 구조가 복잡하여 여기에 직접 포함하기 어렵습니다.
# 주로 models.py, views.py, urls.py, admin.py 등에 코드가 나뉘어 작성됩니다.
# (예시: myapp/views.py)
# from django.shortcuts import render
# from django.http import HttpResponse

# def index(request):
#     return HttpResponse("Hello, Django!")
