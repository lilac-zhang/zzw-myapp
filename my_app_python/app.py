import boto3
import uuid

s3 = boto3.client("s3")
BUCKET = "zzw-myapp-images-123456"

import os
from dotenv import load_dotenv

load_dotenv()

from flask import Flask, request, redirect, render_template
import psycopg2
print("VERSION CHECK 123456")
app = Flask(__name__)

# DB（local docker）
print("DB_HOST =", os.getenv("DB_HOST"))
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

# frist date
def init_db():
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS todos (
        id SERIAL PRIMARY KEY,
        title TEXT,
        done BOOLEAN,
        image_url TEXT
    )
    """)
    conn.commit()
    cur.close()

init_db()

#  todo
@app.route("/")
def index():
    cur = conn.cursor()
    cur.execute("SELECT id, title, done, image_url FROM todos")
    todos = cur.fetchall()
    cur.close()
    return render_template("index.html", todos=todos)

# add
@app.route("/add", methods=["GET", "POST"])
def add():
    if request.method == "POST":
        title = request.form["title"]
        file = request.files.get("image")

        image_url = None

    if file:
        filename = str(uuid.uuid4()) + "_" + file.filename
        s3.upload_fileobj(file, BUCKET, filename)
        image_url = f"https://{BUCKET}.s3.amazonaws.com/{filename}"

    cur = conn.cursor()
    cur.execute(
         "INSERT INTO todos (title, done, image_url) VALUES (%s, false, %s)",
         (title, image_url)
    )
    conn.commit()
    cur.close()

    return redirect("/")

    return render_template("add.html")

# edit
@app.route("/<int:id>/edit", methods=["GET", "POST"])
def edit(id):
    cur = conn.cursor()

    if request.method == "POST":
        title = request.form["title"]
        cur.execute("UPDATE todos SET title=%s WHERE id=%s", (title, id))
        conn.commit()
        cur.close()
        return redirect("/")

    cur.execute("SELECT title FROM todos WHERE id=%s", (id,))
    todo = cur.fetchone()
    cur.close()

    return render_template("edit.html", todo=todo)

# delete
@app.route("/<int:id>/delete")
def delete(id):
    cur = conn.cursor()
    cur.execute("DELETE FROM todos WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    return redirect("/")

# mark active
@app.route("/<int:id>/toggle")
def toggle(id):
    cur = conn.cursor()
    cur.execute("UPDATE todos SET done = NOT done WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    return redirect("/")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

