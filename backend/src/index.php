<?php

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function response($status, $data) {
    http_response_code($status);
    echo json_encode($data);
    exit;
}

try {
    $pdo = new PDO(
        'mysql:host=db;dbname=products_db;charset=utf8mb4',
        'products_user',
        'products123',
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
        ]
    );
} catch (PDOException $e) {
    response(500, ['message' => 'Koneksi database gagal']);
}

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$segments = explode('/', trim($path, '/'));

if (($segments[0] ?? '') !== 'api' ||
    ($segments[1] ?? '') !== 'products') {
    response(404, ['message' => 'Endpoint tidak ditemukan']);
}

$id = isset($segments[2]) ? (int) $segments[2] : null;

if ($method === 'GET' && $id === null) {
    $stmt = $pdo->query('SELECT * FROM products ORDER BY id DESC');
    response(200, [
        'products' => $stmt->fetchAll()
    ]);
}

if ($method === 'GET' && $id !== null) {
    $stmt = $pdo->prepare('SELECT * FROM products WHERE id = ?');
    $stmt->execute([$id]);
    $product = $stmt->fetch();

    if (!$product) {
        response(404, ['message' => 'Produk tidak ditemukan']);
    }

    response(200, $product);
}

if ($method === 'POST' && $id === null) {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!is_array($data) ||
        empty(trim($data['title'] ?? ''))) {
        response(422, ['message' => 'Nama produk wajib diisi']);
    }

    $stmt = $pdo->prepare(
        'INSERT INTO products
        (title, description, price, category, thumbnail, stock)
        VALUES (?, ?, ?, ?, ?, ?)'
    );

    $stmt->execute([
        trim($data['title']),
        $data['description'] ?? '',
        $data['price'] ?? 0,
        $data['category'] ?? '',
        $data['thumbnail'] ?? '',
        $data['stock'] ?? 0
    ]);

    $newId = (int) $pdo->lastInsertId();

    $stmt = $pdo->prepare('SELECT * FROM products WHERE id = ?');
    $stmt->execute([$newId]);

    response(201, [
        'message' => 'Produk berhasil ditambahkan',
        'product' => $stmt->fetch()
    ]);
}

if (in_array($method, ['PUT', 'PATCH']) && $id !== null) {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!is_array($data)) {
        response(400, ['message' => 'Format JSON tidak valid']);
    }

    $stmt = $pdo->prepare('SELECT * FROM products WHERE id = ?');
    $stmt->execute([$id]);
    $existing = $stmt->fetch();

    if (!$existing) {
        response(404, ['message' => 'Produk tidak ditemukan']);
    }

    $fields = [
        'title' => $existing['title'],
        'description' => $existing['description'],
        'price' => $existing['price'],
        'category' => $existing['category'],
        'thumbnail' => $existing['thumbnail'],
        'stock' => $existing['stock']
    ];

    foreach ($fields as $key => $value) {
        if (array_key_exists($key, $data)) {
            $fields[$key] = $data[$key];
        }
    }

    if (trim((string) $fields['title']) === '') {
        response(422, ['message' => 'Nama produk wajib diisi']);
    }

    $stmt = $pdo->prepare(
        'UPDATE products SET
        title = ?, description = ?, price = ?,
        category = ?, thumbnail = ?, stock = ?
        WHERE id = ?'
    );

    $stmt->execute([
        $fields['title'],
        $fields['description'],
        $fields['price'],
        $fields['category'],
        $fields['thumbnail'],
        $fields['stock'],
        $id
    ]);

    $stmt = $pdo->prepare('SELECT * FROM products WHERE id = ?');
    $stmt->execute([$id]);

    response(200, [
        'message' => 'Produk berhasil diperbarui',
        'product' => $stmt->fetch()
    ]);
}

if ($method === 'DELETE' && $id !== null) {
    $stmt = $pdo->prepare('DELETE FROM products WHERE id = ?');
    $stmt->execute([$id]);

    if ($stmt->rowCount() === 0) {
        response(404, ['message' => 'Produk tidak ditemukan']);
    }

    response(200, ['message' => 'Produk berhasil dihapus']);
}

response(405, ['message' => 'Method tidak diizinkan']);
