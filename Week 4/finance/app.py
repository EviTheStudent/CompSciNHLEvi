import os

from cs50 import SQL
from flask import Flask, flash, redirect, render_template, request, session
from flask_session import Session
from werkzeug.security import check_password_hash, generate_password_hash

from helpers import apology, login_required, lookup, usd

# Configure application
app = Flask(__name__)

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Configure CS50 Library to use SQLite database
db = SQL("sqlite:///finance.db")


@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/")
@login_required
def index():
    """Show portfolio of stocks"""
    rows = db.execute("SELECT symbol, amount FROM stocks WHERE user_id = ?", session["user_id"])
    sum = 0 #set the base value to 0, and update
    for row in rows:
        row["price"] = lookup(row["symbol"])["price"]
        row["total"] = row["amount"]*row["price"]
        sum += row["total"]

    #get users cash
    cash = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])[0]["cash"]

    return render_template("index.html", cash=cash, rows=rows, value=cash + sum)


@app.route("/buy", methods=["GET", "POST"])
@login_required
def buy():
    """Buy shares of stock"""
    if request.method == "POST":
        #valid
        if not request.form.get("symbol"):
            return apology("Gimme SOMETHING ", 400)

        if not request.form.get("shares"):
            return apology("Number of shares plessssss", 400)

        if not lookup(request.form.get("symbol").upper()):
            return apology("Uhm... can't find that...", 400)

        if not request.form.get("shares").isdigit() or int(request.form.get("shares")) < 1:
            if int(request.form.get("shares")) == 0:
                return apology("You can't have 0 shares...", 400)
            if int(request.form.get("shares")) < 0:
                return redirect("/sell")
            
    
        cash = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])[0]["cash"]
        Company = request.form.get("symbol").upper()
        cost = lookup(symbol)["price"]
        amount = int(request.form.get("shares")) #You know I forget int exists... big fan of intfrombyte as well ::D

        if amount*price > cash:
            return apology("Wha... no...", 420)

        db.execute("UPDATE users SET cash = ? WHERE id = ?", (cash - (amount*price)), session["user_id"])

        #add to history
        db.execute("INSERT INTO history (user_id, symbol, shares, price) VALUES (?, ?, ?, ?);", session["user_id"], symbol, amount, (amount*price))
    
        try:
            db.execute("SELECT * FROM stocks WHERE user_id = ? AND symbol = ? LIMIT 1", session["user_id"], symbol)
        except:
            db.execute("INSERT INTO stocks (user_id, symbol, amount) VALUES (?, ?, ?);", session["user_id"], symbol, amount)
            flash(f"({symbol}) Successfully bought {amount} stocks for {usd(amount * price)}")
            return redirect("/")
        else: 
            db.execute("UPDATE stocks SET amount = ? WHERE user_id = ? AND symbol = ?;", amount + 
            db.execute("SELECT * FROM stocks WHERE user_id = ? AND symbol = ? LIMIT 1", session["user_id"], symbol)[0]["amount"],
            session["user_id"], symbol) #Too lazy to make a variable...
            flash(f"({symbol}) Successfully bought {amount} stocks for {usd(amount * price)}")
            return redirect("/")
    
    else:
        return render_template("buy.html")

@app.route("/history")
@login_required
def history():
    """Show history of transactions"""
    return render_template("history.html", rows=db.execute("SELECT symbol, shares, price, transacted FROM history WHERE user_id = ?", session["user_id"]))


@app.route("/login", methods=["GET", "POST"])
def login():
    """Log user in"""

    # Forget any user_id
    session.clear()

    # User reached route via POST (as by submitting a form via POST)
    if request.method == "POST":
        # Ensure username was submitted
        if not request.form.get("username"):
            return apology("must provide username", 403)

        # Ensure password was submitted
        elif not request.form.get("password"):
            return apology("must provide password", 403)

        # Query database for username
        rows = db.execute(
            "SELECT * FROM users WHERE username = ?", request.form.get("username")
        )

        # Ensure username exists and password is correct
        if len(rows) != 1 or not check_password_hash(
            rows[0]["hash"], request.form.get("password")
        ):
            return apology("invalid username and/or password", 403)

        # Remember which user has logged in
        session["user_id"] = rows[0]["id"]

        # Redirect user to home page
        return redirect("/")

    # User reached route via GET (as by clicking a link or via redirect)
    else:
        return render_template("login.html")


@app.route("/logout")
def logout():
    """Log user out"""

    # Forget any user_id
    session.clear()

    # Redirect user to login form
    return redirect("/")


@app.route("/quote", methods=["GET", "POST"])
@login_required
def quote():
    """Get stock quote."""
    if request.method == "POST":
        if not request.form.get("symbol"):
            return apology("Symbol pleaseeeee >>w<<", 400)
        if not lookup(request.form.get("symbol")):
            return apology("We couldn't find that symbol TTwTT", 400)

        return render_template("quoted.html", look=lookup(request.form.get("symbol")))
    #default
    else:  
        return render_template("quote.html")

@app.route("/register", methods=["GET", "POST"])
def register():
    """Register user"""
    if request.method == "POST":
        if not request.form.get("username"):
            return apology("pwease gib us a user nameeeee", 400)
        elif not request.form.get("password"):
            return apology("mwust pwovide password", 400)
        elif not request.form.get("Password2"):
            return apology("mwust wepeat password", 400)

        elif not (request.form.get("password") == request.form.get("Password2")):
            return apology("password must match >>~<<", 400)

        #try adding new user into database
        try:
            db.execute("INSERT INTO users (username, hash, cash) VALUES (?, ?, 10000);", request.form.get(
                "username"), generate_password_hash(request.form.get("password")))
            return redirect("/")
        #if it throws an error, assume the username is faulty ::D
        except:
            return apology("username already taken", 400)

    else:
        return render_template("register.html")

@app.route("/sell", methods=["GET", "POST"])
@login_required
def sell():
    """Sell shares of stock"""
    if request.method == "POST":
        if not request.form.get("symbol"):
            return apology("Gimme SOMETHING ", 400)

        if not request.form.get("shares"):
            return apology("Number of shares plessssss", 400)

        if not lookup(request.form.get("symbol").upper()):
            return apology("Uhm... can't find that...", 400)

        if not request.form.get("shares").isdigit() or int(request.form.get("shares")) < 1:
            return apology("not this time")

        cash = db.execute("SELECT cash FROM users WHERE id = ?", session["user_id"])[0]["cash"]
        Company = request.form.get("symbol").upper()
        cost = lookup(symbol)["price"]
        amount = int(request.form.get("shares")) #what is selling if not inverse buying

        if amount > db.execute( "SELECT amount FROM stocks WHERE user_id = ? AND symbol = ? LIMIT 1", session["user_id"], symbol)[0]["amount"]:
            return apology("Too many you don't have that to sell", 400)
        
        db.execute("UPDATE users SET cash = ? WHERE id = ?", (cash + (amount*price)), session["user_id"])

        #add to history
        db.execute("INSERT INTO history (user_id, symbol, shares, price) VALUES (?, ?, ?, ?);", session["user_id"], symbol, -amount, amount*price)

        if (db.execute( "SELECT amount FROM stocks WHERE user_id = ? AND symbol = ? LIMIT 1", session["user_id"], symbol)[0]["amount"]-amount == 0):  # delete if none left
            db.execute("DELETE FROM stocks WHERE user_id = ? AND symbol = ?;", session["user_id"], symbol)
        else:
            db.execute("UPDATE stocks SET amount = ? WHERE user_id = ? AND symbol = ?;", db.execute( "SELECT amount FROM stocks WHERE user_id = ? AND symbol = ? LIMIT 1", session["user_id"], symbol)[0]["amount"] - amount, session["user_id"], symbol)
            
        flash(f"({symbol}) Successfully sold {amount} stocks for {usd(amount * price)}")

        return redirect("/")

    else: 
        return render_template("sell.html", owned=db.execute("SELECT symbol FROM stocks WHERE user_id = ?", session["user_id"]))


    