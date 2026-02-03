<?php

namespace App\Controllers;

use App\Core\Request;
use App\Models\Product;
use PDO;

class ProductController extends BaseController {
    private $product;
    
    public function __construct() {
        $this->product = new Product();
    }
    
    public function getAll(Request $request) {
        $stmt = $this->product->getAll();
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->success($products);
    }
    
    public function getBySeller(Request $request) {
        $sellerId = $request->getBody()['seller_id'] ?? null;
        if (!$sellerId) return $this->error('Seller ID required');
        
        $stmt = $this->product->getBySeller($sellerId);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->success($products);
    }
    
    public function getByCategory(Request $request) {
        $category = $request->getBody()['category'] ?? null;
        if (!$category) return $this->error('Category required');
        
        $stmt = $this->product->getByCategory($category);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->success($products);
    }
    
    public function getProduct(Request $request) {
        $id = $request->getBody()['id'] ?? $request->getParam(0);
        if (!$id) return $this->error('Product ID required');
        
        $productData = $this->product->getById($id);
        if ($productData) {
            return $this->success($productData);
        }
        return $this->error('Product not found', 404);
    }
    
    public function create(Request $request) {
        $currentUser = $GLOBALS['current_user'] ?? null;
        $role = isset($currentUser['role']) ? strtolower($currentUser['role']) : null;
        
        if (!$currentUser || $role !== 'seller') {
            return $this->error('Access denied', 403);
        }
        
        $data = $request->getBody();
        $this->product->name = $data['name'] ?? '';
        $this->product->description = $data['description'] ?? '';
        $this->product->price = $data['price'] ?? 0;
        $this->product->image_url = $data['image_url'] ?? '';
        $this->product->category = $data['category'] ?? '';
        $this->product->seller_id = $currentUser['id'];
        
        if ($this->product->create()) {
            return $this->success(['id' => $this->product->id], 'Product created successfully');
        }
        return $this->error('Failed to create product', 500);
    }
    
    public function update(Request $request) {
        $currentUser = $GLOBALS['current_user'] ?? null;
        $role = isset($currentUser['role']) ? strtolower($currentUser['role']) : null;
        
        if (!$currentUser || $role !== 'seller') {
            return $this->error('Access denied', 403);
        }
        
        $data = $request->getBody();
        $this->product->id = $data['id'] ?? null;
        $this->product->seller_id = $currentUser['id'];
        
        if (!$this->product->id) return $this->error('Product ID required');

        $this->product->name = $data['name'] ?? '';
        $this->product->description = $data['description'] ?? '';
        $this->product->price = $data['price'] ?? 0;
        $this->product->image_url = $data['image_url'] ?? '';
        $this->product->category = $data['category'] ?? '';
        
        if ($this->product->update()) {
            return $this->success(null, 'Product updated successfully');
        }
        return $this->error('Failed to update product', 500);
    }
    
    public function delete(Request $request) {
        $currentUser = $GLOBALS['current_user'] ?? null;
        $role = isset($currentUser['role']) ? strtolower($currentUser['role']) : null;
        
        if (!$currentUser || $role !== 'seller') {
            return $this->error('Access denied', 403);
        }
        
        $data = $request->getBody();
        $this->product->id = $data['id'] ?? null;
        $this->product->seller_id = $currentUser['id'];
        
        if (!$this->product->id) return $this->error('Product ID required');

        if ($this->product->delete()) {
            return $this->success(null, 'Product deleted successfully');
        }
        return $this->error('Failed to delete product', 500);
    }
    
    public function search(Request $request) {
        $query = $request->getBody()['q'] ?? '';
        $stmt = $this->product->search($query);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->success($products);
    }
}
