import boto3
import uuid
import os
import psycopg2
from flask import Flask, request, redirect, render_template

print("VERSION CHECK ECS")

app = Flask(__name__)

# S3
s3 = boto3.client("s3", region_name="ap-northeast-1")
BUCKET = os.getenv("BUCKET")

# DB
def get_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )


# initialization DB
def init_db():
    try:
        conn = get_conn()
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
        conn.close()
    except Exception as e:
        print("DB init failed:", e)

init_db()


# front page
@app.route("/")
def index():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("SELECT id, title, done, image_url FROM todos")
    todos = cur.fetchall()
    cur.close()
    conn.close()
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

        conn = get_conn()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO todos (title, done, image_url) VALUES (%s, false, %s)",
            (title, image_url)
        )
        conn.commit()
        cur.close()
        conn.close()

        return redirect("/")

    return render_template("add.html")

# edit
@app.route("/<int:id>/edit", methods=["GET", "POST"])
def edit(id):
    conn = get_conn()
    cur = conn.cursor()

    if request.method == "POST":
        title = request.form["title"]
        cur.execute("UPDATE todos SET title=%s WHERE id=%s", (title, id))
        conn.commit()
        cur.close()
        conn.close()
        return redirect("/")

    cur.execute("SELECT title FROM todos WHERE id=%s", (id,))
    todo = cur.fetchone()
    cur.close()
    conn.close()

    return render_template("edit.html", todo=todo)


# delete
@app.route("/<int:id>/delete")
def delete(id):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("DELETE FROM todos WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")

# toogle
@app.route("/<int:id>/toggle")
def toggle(id):
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("UPDATE todos SET done = NOT done WHERE id=%s", (id,))
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")

# main
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)