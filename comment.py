from flask import Flask, request, jsonify

app = Flask(__name__)

# Armazenar os comentários em um dicionário onde a chave é o ID da matéria
comments = {}

@app.route('/api/comment/new', methods=['POST'])
def create_comment():
    data = request.get_json()
    email = data.get('email')
    comment = data.get('comment')
    content_id = data.get('content_id')

    if not email or not comment or content_id is None:
        return jsonify({'error': 'Missing required fields'}), 400

    if content_id not in comments:
        comments[content_id] = []

    comments[content_id].append({'email': email, 'comment': comment})
    return jsonify({'message': 'Comment created successfully'}), 201

@app.route('/api/comment/list/<int:content_id>', methods=['GET'])
def list_comments(content_id):
    if content_id not in comments:
        return jsonify({'error': 'Content not found'}), 404

    return jsonify(comments[content_id])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)