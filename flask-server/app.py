from flask import Flask, request, jsonify # type: ignore
from flask_cors import CORS # type: ignore
import json
import os
import random

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

CART_FILE = 'cart.json'
PRODUCT_LIST = 'product.json'

# Function that randomizes the featured items
@app.route('/api/products/featured', methods=['GET'])
def get_featured_products():
    try:
        # Load the products from the JSON file
        with open(PRODUCT_LIST, 'r') as file:
            data = json.load(file)
            products = data.get('products', [])

        # Randomly select a few products to feature (let's say 4)
        featured_products = random.sample(products, 4)

        return jsonify({'products': featured_products})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Load products from products.json
def load_products():
    with open(PRODUCT_LIST) as f:
        return json.load(f)

@app.route('/api/products', methods=['GET'])
def get_products():
    products = load_products()
    return jsonify(products)

# Function to read the cart from the JSON file
def read_cart():
    if os.path.exists(CART_FILE):
        with open(CART_FILE, 'r') as f:
            return json.load(f)
    return []

# Function to write the cart to the JSON file
def write_cart(cart):
    with open(CART_FILE, 'w') as f:
        json.dump(cart, f)

@app.route('/api/cart', methods=['GET', 'POST'])
def manage_cart():
    if request.method == 'GET':
        cart = read_cart()
        return jsonify(cart)
    elif request.method == 'POST':
        item = request.get_json()
        cart = read_cart()

        # Find the item in the cart based on the ID
        for cart_item in cart:
            if cart_item['id'] == item['id']:
                cart_item['quantity'] = item['quantity']  # Set quantity directly from the request
                break
        else:
            # If the item is not in the cart, add it with the specified quantity
            cart.append(item)
        
        write_cart(cart)
        return jsonify({'message': 'Cart updated successfully'}), 201



@app.route('/api/cart/<item_id>', methods=['DELETE'])
def remove_from_cart(item_id):
    cart = read_cart()
    new_cart = [item for item in cart if str(item.get('id')) != str(item_id)]
    
    if len(new_cart) != len(cart):
        write_cart(new_cart)
        return jsonify({'message': f'Item {item_id} removed from cart'}), 200
    else:
        return jsonify({'message': f'Item {item_id} not found in cart'}), 404

if __name__ == '__main__':
    app.run(debug=True)
