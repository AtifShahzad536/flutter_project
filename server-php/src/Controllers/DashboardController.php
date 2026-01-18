<?php

namespace App\Controllers;

use App\Core\Request;
use App\Models\Order;
use PDO;
use Exception;

class DashboardController extends BaseController {
    private $order;
    
    public function __construct() {
        $this->order = new Order();
    }
    
    public function getDashboardStats(Request $request) {
        $currentUser = \App\Middleware\AuthMiddleware::getUser();
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied. Dashboard is for riders only.', 403);
        }
        
        try {
            $rider_id = $currentUser['id'];
            $stats = $this->order->getByRider($rider_id)->fetchAll(PDO::FETCH_ASSOC);
            
            $completedOrders = 0;
            $activeOrdersCount = 0;
            $totalEarnings = 0;
            $activeOrder = null;
            
            foreach ($stats as $order) {
                if ($order['status'] === 'Delivered') {
                    $completedOrders++;
                    $totalEarnings += (float)($order['total_amount'] * 0.1);
                } else if (in_array($order['status'], ['Picked', 'OnTheWay'])) {
                    $activeOrdersCount++;
                    $activeOrder = $order;
                }
            }

            $earningsGraph = [];
            for ($i = 6; $i >= 0; $i--) {
                $date = date('Y-m-d', strtotime("-$i days"));
                $dayName = date('D', strtotime($date));
                $dayEarnings = 0;
                foreach ($stats as $order) {
                    if ($order['status'] === 'Delivered' && strpos($order['created_at'], $date) === 0) {
                        $dayEarnings += (float)($order['total_amount'] * 0.1);
                    }
                }
                $earningsGraph[] = ['day' => $dayName, 'amount' => $dayEarnings];
            }

            // Monthly orders trend for the last 6 months
            $monthlyOrders = [];
            for ($i = 5; $i >= 0; $i--) {
                $monthStr = date('Y-m', strtotime("-$i months"));
                $monthName = date('M', strtotime($monthStr . "-01"));
                $count = 0;
                foreach ($stats as $order) {
                    if (strpos($order['created_at'], $monthStr) === 0) {
                        $count++;
                    }
                }
                $monthlyOrders[] = ['month' => $monthName, 'orders' => $count];
            }
            
            return $this->success([
                'today_earnings' => (float)$totalEarnings,
                'total_orders' => $completedOrders,
                'active_orders' => $activeOrdersCount,
                'hours_online' => "6h 20m",
                'avg_rating' => 4.9,
                'earningsGraph' => $earningsGraph,
                'monthly_orders' => $monthlyOrders,
                'active_order' => $activeOrder,
                'recentOrders' => array_slice($stats, 0, 5)
            ]);
            
        } catch (Exception $e) {
            return $this->error('Server Error: ' . $e->getMessage(), 500);
        }
    }
    
    public function getRiderStats(Request $request) {
        $currentUser = \App\Middleware\AuthMiddleware::getUser();
        if (!$currentUser || $currentUser['role'] !== 'rider') {
            return $this->error('Access denied', 403);
        }
        
        try {
            $stmt = $this->order->getByRider($currentUser['id']);
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            $completedOrders = 0;
            $totalEarnings = 0;
            
            foreach ($orders as $order) {
                if ($order['status'] === 'Delivered') {
                    $completedOrders++;
                    $totalEarnings += $order['total_amount'] * 0.1;
                }
            }
            
            $activeOrdersCount = count(array_filter($orders, function($order) {
                return in_array($order['status'], ['Pending', 'Picked', 'OnTheWay']);
            }));
            
            return $this->success([
                'totalOrders' => count($orders),
                'completedOrders' => $completedOrders,
                'activeOrders' => $activeOrdersCount,
                'totalEarnings' => (float)$totalEarnings,
                'averageRating' => 4.9,
                'hoursOnline' => "6h 20m",
                'today_earnings' => (float)$totalEarnings,
                'total_orders' => $completedOrders,
                'avg_rating' => 4.9,
                'hours_online' => "6h 20m"
            ]);
            
        } catch (Exception $e) {
            return $this->error('Server Error: ' . $e->getMessage(), 500);
        }
    }
    
    public function getAdminStats(Request $request) {
        $currentUser = \App\Middleware\AuthMiddleware::getUser();
        if (!$currentUser || $currentUser['role'] !== 'admin') {
            return $this->error('Access denied', 403);
        }
        
        return $this->success([
            'totalUsers' => 150,
            'totalOrders' => 450,
            'totalProducts' => 85,
            'totalRevenue' => 12500.50,
            'activeRiders' => 25,
            'recentOrders' => [],
            'userGrowth' => [
                ['month' => 'Jan', 'users' => 100],
                ['month' => 'Feb', 'users' => 120],
                ['month' => 'Mar', 'users' => 150]
            ]
        ]);
    }
}
