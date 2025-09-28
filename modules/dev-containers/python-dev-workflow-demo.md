# Python Development Workflow Demo

## Container Options Available

You now have **two different Python development container approaches**:

### **Option A: Real Debian Container** (Recommended)
- Uses actual Debian Trixie with `apt` and `dpkg`
- Install packages with `apt install`
- More like traditional Linux development
- File: `./modules/dev-containers/debian-python-dev-container.nix`

### **Option B: NixOS Container**
- Uses NixOS packages and Nix store
- Declarative package management
- File: `./modules/dev-containers/nixos-python-dev-container.nix`

## Step 1: Choose and Add Container to Your NixOS Configuration

### For Real Debian Container (Recommended):
```nix
# In flake.nix, add to your deck extraModules:
{
  host = "deck";
  extraModules = [
    # ... your existing modules ...
    ./modules/dev-containers/debian-python-dev-container.nix  # Real Debian
  ];
}
```

### For NixOS Container:
```nix
# In flake.nix, add to your deck extraModules:
{
  host = "deck";
  extraModules = [
    # ... your existing modules ...
    ./modules/dev-containers/nixos-python-dev-container.nix  # NixOS container
  ];
}
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake ~/nixos-configuration/#deck
```

## Step 2: Create and Start the Container

### For Debian Container:
```bash
# Create the Debian container
debian-python-dev create

# Set up Python development environment
debian-python-dev setup

# Start the container
debian-python-dev shell
```

Expected output after setup:
```
Debian Python Development Container
- Real Debian Trixie with apt/dpkg
- Python 3.11+ with uv package manager
- User: debian (password: debian)
- SSH enabled

Shared directories:
  Host /home/luiz/.python → Container /home/debian/.python
  Host /home/luiz/.cache/uv → Container /home/debian/.cache/uv

Quick start:
  cd .python/sample-project
  uv venv && source .venv/bin/activate
  uv pip install -e .
  python main.py
```

### For NixOS Container:
```bash
# Start the NixOS container
python-dev start
```

Expected output:
```
Python development container started!

Available Python versions:
  python3, python3.9, python3.10, python3.11, python3.12

Development tools installed:
  - uv (fast package installer), pip, virtualenv
  - PostgreSQL, Redis, SQLite
  - VS Code Server, vim, neovim
  - Node.js, yarn

Shared directories:
  Host /home/luiz/.python → Container /home/dev/.python
  Host /home/luiz/.cache/uv → Container /home/dev/.cache/uv

Use 'python-dev shell' to access the container
```

## Step 3: Create a New Python Project

### For Debian Container:
```bash
# Create a new Flask web application project
debian-python-dev create-project flask-todo-app
```

### For NixOS Container:
```bash
# Create a new Flask web application project
python-dev create-project flask-todo-app
```

This creates:
```
/home/luiz/.python/flask-todo-app/
├── pyproject.toml    # Modern Python project file
├── README.md
└── main.py
```

## Step 4: Enter the Container and Set Up the Project

### For Debian Container:
```bash
# Get a shell in the container (if not already in it)
debian-python-dev shell
```

Now you're inside the Debian container as the 'debian' user:

```bash
# Navigate to your project
cd .python/flask-todo-app

# Check available Python versions
python3 --version

# Create virtual environment with uv (fast!)
uv venv
source .venv/bin/activate

# Your prompt should now show (.venv)
```

### For NixOS Container:
```bash
# Get a shell in the container
python-dev shell
```

Now you're inside the NixOS container as the 'dev' user:

```bash
# Navigate to your project
cd .python/flask-todo-app

# Check available Python versions
python3 --version
python3.11 --version
python3.12 --version

# Create virtual environment with uv
uv venv
source .venv/bin/activate

# Your prompt should now show (.venv)
```

## Step 5: Install Dependencies and Develop

```bash
# Install Flask and other dependencies with uv (much faster than pip!)
uv pip install flask flask-sqlalchemy python-dotenv

# Update pyproject.toml dependencies
# Edit the dependencies section in pyproject.toml to include:
# dependencies = [
#     "flask>=2.3.0",
#     "flask-sqlalchemy>=3.0.0", 
#     "python-dotenv>=1.0.0",
# ]

# Create a simple Flask app
cat > app.py << 'EOF'
from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///todo.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    complete = db.Column(db.Boolean, default=False)

@app.route('/')
def index():
    todos = Todo.query.all()
    return f"""
    <h1>Todo App</h1>
    <form method="POST" action="/add">
        <input type="text" name="title" placeholder="Add new todo" required>
        <button type="submit">Add</button>
    </form>
    <ul>
        {''.join([f'<li>{"✓" if todo.complete else "○"} {todo.title} <a href="/toggle/{todo.id}">Toggle</a></li>' for todo in todos])}
    </ul>
    """

@app.route('/add', methods=['POST'])
def add():
    title = request.form.get('title')
    new_todo = Todo(title=title)
    db.session.add(new_todo)
    db.session.commit()
    return redirect(url_for('index'))

@app.route('/toggle/<int:id>')
def toggle(id):
    todo = Todo.query.get_or_404(id)
    todo.complete = not todo.complete
    db.session.commit()
    return redirect(url_for('index'))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)
EOF

# Run the Flask application
python app.py
```

## Step 6: Access Your Application

The Flask app is now running inside the container on port 5000. Since we're sharing the network, you can access it from your host:

```bash
# From your host (Steam Deck), open browser to:
http://localhost:5000
```

## Step 7: Database Development

```bash
# The container has PostgreSQL running, let's use it
pip install psycopg2-binary

# Connect to PostgreSQL (running in container)
python3 -c "
import psycopg2
conn = psycopg2.connect(
    host='localhost',
    database='postgres',
    user='postgres'
)
print('Connected to PostgreSQL!')
conn.close()
"

# Or use Redis
pip install redis
python3 -c "
import redis
r = redis.Redis(host='localhost', port=6379, db=0)
r.set('test', 'Hello from container!')
print(r.get('test').decode())
"
```

## Step 8: Advanced Development Features

### A. Use Poetry for Dependency Management
```bash
# Initialize poetry project
poetry init --no-interaction
poetry add flask flask-sqlalchemy
poetry add --group dev pytest black flake8

# Install dependencies
poetry install

# Run with poetry
poetry run python app.py
```

### B. Start Jupyter Lab for Data Science
```bash
# Exit the container first (Ctrl+D)
# Then start Jupyter from host:
python-dev jupyter
```

Access Jupyter at: `http://localhost:8888`

### C. Use Multiple Python Versions
```bash
# Inside container, test with different Python versions
python3.9 -m venv venv39
python3.10 -m venv venv310
python3.11 -m venv venv311
python3.12 -m venv venv312

# Activate any version you want
source venv311/bin/activate
```

## Step 9: File Sharing Between Host and Container

Files are automatically shared through bind mounts:

```bash
# From your Steam Deck host:
ls /home/luiz/.python/flask-todo-app/

# Edit files with your favorite editor on the host:
code /home/luiz/.python/flask-todo-app/app.py
# or
vim /home/luiz/.python/flask-todo-app/app.py

# Changes are immediately available in the container!
```

### Container-Specific Paths:

**Debian Container:**
- Host: `/home/luiz/.python/` → Container: `/home/debian/.python/`
- Host: `/home/luiz/.cache/uv/` → Container: `/home/debian/.cache/uv/`

**NixOS Container:**
- Host: `/home/luiz/.python/` → Container: `/home/dev/.python/`
- Host: `/home/luiz/.cache/uv/` → Container: `/home/dev/.cache/uv/`

## Step 10: Container Management

### For Debian Container:
```bash
# Check container status
debian-python-dev status

# Get shell when needed
debian-python-dev shell

# Remove container completely
debian-python-dev remove

# Recreate if needed
debian-python-dev create
debian-python-dev setup
```

### For NixOS Container:
```bash
# Check container status
python-dev status

# Stop the container when done
python-dev stop

# Restart later
python-dev start
python-dev shell
cd .python/flask-todo-app
source .venv/bin/activate
# Continue working...
```

## Step 11: Advanced Workflow - Multiple Projects

```bash
# Create different types of projects
python-dev create-project django-blog
python-dev create-project fastapi-api
python-dev create-project data-analysis
python-dev create-project ml-experiment

# Each project is isolated with its own virtual environment
python-dev shell
cd python-projects/django-blog
python3.11 -m venv venv && source venv/bin/activate
pip install django

cd ../fastapi-api
python3.12 -m venv venv && source venv/bin/activate
pip install fastapi uvicorn

# etc...
```

## Benefits of This Workflow

1. **Isolation**: Container keeps your host system clean
2. **Multiple Python versions**: Test compatibility easily
3. **Persistent storage**: Projects saved on host filesystem
4. **Database access**: PostgreSQL, Redis, SQLite available
5. **Development tools**: VS Code Server, Jupyter, etc.
6. **Easy sharing**: Edit files on host, run in container
7. **Reproducible**: Same environment every time
8. **Fast**: No VM overhead, native performance

## Troubleshooting

```bash
# If container won't start:
sudo nixos-container status debian-python-dev
sudo journalctl -u container@debian-python-dev

# Reset container:
sudo nixos-container stop debian-python-dev
sudo rm -rf /var/lib/nixos-containers/debian-python-dev
sudo nixos-rebuild switch --flake ~/nixos-configuration/#deck

# Check bind mounts:
ls -la /home/luiz/python-projects/
```

This workflow gives you a complete, isolated Python development environment that's easy to manage and doesn't interfere with your gaming setup!