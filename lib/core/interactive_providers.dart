import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../features/vehicle_tracker/domain/vehicle_model.dart';

// ==========================================
// 1. WALLET STATE SYSTEM
// ==========================================

class WalletState {
  final double balance;
  final int points;
  final double cashback;
  final List<Transaction> transactions;
  final List<Map<String, String>> paymentMethods;

  WalletState({
    required this.balance,
    required this.points,
    required this.cashback,
    required this.transactions,
    required this.paymentMethods,
  });

  WalletState copyWith({
    double? balance,
    int? points,
    double? cashback,
    List<Transaction>? transactions,
    List<Map<String, String>>? paymentMethods,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      points: points ?? this.points,
      cashback: cashback ?? this.cashback,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState(
    balance: 15000.00,
    points: 2450,
    cashback: 350.00,
    paymentMethods: [
      {'type': 'Visa', 'last4': '4242', 'expiry': '12/28', 'name': 'Alex Pierce'},
      {'type': 'Mastercard', 'last4': '8839', 'expiry': '09/27', 'name': 'Alex Pierce'},
    ],
    transactions: [
      Transaction(
        id: 'tx-001',
        title: 'Airport Taxi Booking',
        amount: 800.00,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isCredit: false,
        category: 'Ride',
      ),
      Transaction(
        id: 'tx-002',
        title: 'Tire Air Replacement Kit',
        amount: 3500.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        isCredit: false,
        category: 'Store',
      ),
      Transaction(
        id: 'tx-003',
        title: 'Visa Top-up Loaded',
        amount: 10000.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        isCredit: true,
        category: 'Deposit',
      ),
    ],
  ));

  void addMoney(double amount, String paymentMethod) {
    final newTx = Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Top-up via $paymentMethod',
      amount: amount,
      date: DateTime.now(),
      isCredit: true,
      category: 'Deposit',
    );

    state = state.copyWith(
      balance: state.balance + amount,
      points: state.points + (amount * 0.5).toInt(),
      transactions: [newTx, ...state.transactions],
    );
  }

  bool transferMoney(double amount, String recipient, String account) {
    if (state.balance < amount) return false;

    final newTx = Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer to $recipient ($account)',
      amount: amount,
      date: DateTime.now(),
      isCredit: false,
      category: 'Transfer',
    );

    state = state.copyWith(
      balance: state.balance - amount,
      transactions: [newTx, ...state.transactions],
    );
    return true;
  }

  bool deductMoney(double amount, String title, String category) {
    if (state.balance < amount) return false;

    final newTx = Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      date: DateTime.now(),
      isCredit: false,
      category: category,
    );

    state = state.copyWith(
      balance: state.balance - amount,
      transactions: [newTx, ...state.transactions],
    );
    return true;
  }

  void addPaymentMethod(String type, String last4, String expiry, String name) {
    state = state.copyWith(
      paymentMethods: [
        ...state.paymentMethods,
        {'type': type, 'last4': last4, 'expiry': expiry, 'name': name}
      ],
    );
  }

  void deletePaymentMethod(int index) {
    final updatedList = List<Map<String, String>>.from(state.paymentMethods)..removeAt(index);
    state = state.copyWith(paymentMethods: updatedList);
  }

  void claimCashback() {
    if (state.cashback <= 0.0) return;
    final amount = state.cashback;
    final newTx = Transaction(
      id: 'tx-cb-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cashback Claim Redeemed',
      amount: amount,
      date: DateTime.now(),
      isCredit: true,
      category: 'Deposit',
    );

    state = state.copyWith(
      balance: state.balance + amount,
      cashback: 0.0,
      transactions: [newTx, ...state.transactions],
    );
  }
}

final walletInteractiveProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) => WalletNotifier());

// ==========================================
// 2. GARAGE STATE SYSTEM
// ==========================================

class GarageState {
  final List<VehicleModel> vehicles;
  final VehicleModel? selectedVehicle;
  final Map<String, bool> locks;
  final Map<String, bool> climate;
  final Map<String, List<Map<String, dynamic>>> fuelLogs;
  final Map<String, List<String>> vehicleNotes;

  GarageState({
    required this.vehicles,
    this.selectedVehicle,
    required this.locks,
    required this.climate,
    required this.fuelLogs,
    required this.vehicleNotes,
  });

  GarageState copyWith({
    List<VehicleModel>? vehicles,
    VehicleModel? selectedVehicle,
    Map<String, bool>? locks,
    Map<String, bool>? climate,
    Map<String, List<Map<String, dynamic>>>? fuelLogs,
    Map<String, List<String>>? vehicleNotes,
  }) {
    return GarageState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      locks: locks ?? this.locks,
      climate: climate ?? this.climate,
      fuelLogs: fuelLogs ?? this.fuelLogs,
      vehicleNotes: vehicleNotes ?? this.vehicleNotes,
    );
  }
}

class GarageNotifier extends StateNotifier<GarageState> {
  GarageNotifier() : super(_initialState());

  static GarageState _initialState() {
    final defaultVehicles = [
      const VehicleModel(
        id: 'v-001',
        name: 'Tata Nexon EV',
        model: 'XZ+ Lux',
        plateNumber: 'KA-03-MY-8820',
        latitude: 12.9716,
        longitude: 77.5946,
        fuelLevel: 88.0,
        status: 'Parked',
      ),
      const VehicleModel(
        id: 'v-002',
        name: 'Royal Enfield Himalayan',
        model: 'Himalayan 450',
        plateNumber: 'KA-51-HN-4712',
        latitude: 12.9279,
        longitude: 77.6245,
        fuelLevel: 65.0,
        status: 'Active',
      ),
    ];
    return GarageState(
      vehicles: defaultVehicles,
      selectedVehicle: defaultVehicles[0],
      locks: {'v-001': true, 'v-002': true},
      climate: {'v-001': false, 'v-002': false},
      fuelLogs: {
        'v-001': [
          {'date': '2026-06-01', 'amount': 42.0, 'cost': 1250.00, 'odometer': 14200},
          {'date': '2026-05-18', 'amount': 38.0, 'cost': 1140.00, 'odometer': 13850},
        ],
        'v-002': [
          {'date': '2026-06-03', 'amount': 14.2, 'cost': 1820.00, 'odometer': 5210},
        ]
      },
      vehicleNotes: {
        'v-001': ['Check left rear tire alignment at Indiranagar Service Center', 'Insurance due soon'],
        'v-002': ['New chain lubricated in May'],
      },
    );
  }

  void selectVehicle(VehicleModel vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
  }

  void addVehicle(String name, String model, String plateNumber, double fuelLevel) {
    final id = 'v-${DateTime.now().millisecondsSinceEpoch}';
    final newVehicle = VehicleModel(
      id: id,
      name: name,
      model: model,
      plateNumber: plateNumber,
      latitude: 12.9716,
      longitude: 77.5946,
      fuelLevel: fuelLevel,
      status: 'Parked',
    );

    final updatedLocks = Map<String, bool>.from(state.locks)..[id] = true;
    final updatedClimate = Map<String, bool>.from(state.climate)..[id] = false;
    final updatedLogs = Map<String, List<Map<String, dynamic>>>.from(state.fuelLogs)..[id] = [];
    final updatedNotes = Map<String, List<String>>.from(state.vehicleNotes)..[id] = [];

    state = state.copyWith(
      vehicles: [...state.vehicles, newVehicle],
      locks: updatedLocks,
      climate: updatedClimate,
      fuelLogs: updatedLogs,
      vehicleNotes: updatedNotes,
      selectedVehicle: state.selectedVehicle ?? newVehicle,
    );
  }

  void updateVehicle(String id, String name, String model, String plateNumber, double fuelLevel) {
    final updatedVehicles = state.vehicles.map((v) {
      if (v.id == id) {
        return v.copyWith(name: name, model: model, plateNumber: plateNumber, fuelLevel: fuelLevel);
      }
      return v;
    }).toList();

    VehicleModel? newSelected = state.selectedVehicle;
    if (newSelected?.id == id) {
      newSelected = updatedVehicles.firstWhere((v) => v.id == id);
    }

    state = state.copyWith(
      vehicles: updatedVehicles,
      selectedVehicle: newSelected,
    );
  }

  void deleteVehicle(String id) {
    final updatedVehicles = state.vehicles.where((v) => v.id != id).toList();
    VehicleModel? newSelected = state.selectedVehicle;
    if (newSelected?.id == id) {
      newSelected = updatedVehicles.isNotEmpty ? updatedVehicles[0] : null;
    }

    state = state.copyWith(
      vehicles: updatedVehicles,
      selectedVehicle: newSelected,
    );
  }

  void toggleLock(String id) {
    final current = state.locks[id] ?? true;
    final updatedLocks = Map<String, bool>.from(state.locks)..[id] = !current;
    state = state.copyWith(locks: updatedLocks);
  }

  void toggleClimate(String id) {
    final current = state.climate[id] ?? false;
    final updatedClimate = Map<String, bool>.from(state.climate)..[id] = !current;
    state = state.copyWith(climate: updatedClimate);
  }

  void addFuelLog(String vehicleId, double amount, double cost, int odometer) {
    final updatedLogs = Map<String, List<Map<String, dynamic>>>.from(state.fuelLogs);
    final list = List<Map<String, dynamic>>.from(updatedLogs[vehicleId] ?? []);
    list.insert(0, {
      'date': DateTime.now().toString().split(' ')[0],
      'amount': amount,
      'cost': cost,
      'odometer': odometer,
    });
    updatedLogs[vehicleId] = list;
    state = state.copyWith(fuelLogs: updatedLogs);
  }

  void addNote(String vehicleId, String note) {
    final updatedNotes = Map<String, List<String>>.from(state.vehicleNotes);
    final list = List<String>.from(updatedNotes[vehicleId] ?? [])..insert(0, note);
    updatedNotes[vehicleId] = list;
    state = state.copyWith(vehicleNotes: updatedNotes);
  }

  void deleteNote(String vehicleId, int index) {
    final updatedNotes = Map<String, List<String>>.from(state.vehicleNotes);
    final list = List<String>.from(updatedNotes[vehicleId] ?? [])..removeAt(index);
    updatedNotes[vehicleId] = list;
    state = state.copyWith(vehicleNotes: updatedNotes);
  }
}

final garageInteractiveProvider = StateNotifierProvider<GarageNotifier, GarageState>((ref) => GarageNotifier());

// ==========================================
// 3. BOOKINGS SYSTEM
// ==========================================

class PrototypeBooking {
  final String id;
  final String title;
  final String type; // e.g. Ride, Rental, Parking, Hotel, Mechanic, Service
  final DateTime dateTime;
  final String details;
  final String status; // Active, Completed, Cancelled
  final double cost;
  final Map<String, dynamic>? meta; // custom parameters

  PrototypeBooking({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    required this.details,
    required this.status,
    required this.cost,
    this.meta,
  });

  PrototypeBooking copyWith({
    String? id,
    String? title,
    String? type,
    DateTime? dateTime,
    String? details,
    String? status,
    double? cost,
    Map<String, dynamic>? meta,
  }) {
    return PrototypeBooking(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      details: details ?? this.details,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      meta: meta ?? this.meta,
    );
  }
}

class BookingsNotifier extends StateNotifier<List<PrototypeBooking>> {
  BookingsNotifier() : super([
    PrototypeBooking(
      id: 'bk-001',
      title: 'Tata Nexon EV Rental',
      type: 'Rental',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      details: 'Pickup: 10:00 AM • 3 Days Duration',
      status: 'Active',
      cost: 4500.00,
    ),
    PrototypeBooking(
      id: 'bk-002',
      title: 'Tire Diagnostics & Balance',
      type: 'Mechanic',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      details: 'Assigned: Rajesh Kumar • Completed',
      status: 'Completed',
      cost: 1200.00,
    ),
  ]);

  void addBooking(PrototypeBooking booking) {
    state = [booking, ...state];
  }

  void cancelBooking(String id) {
    state = state.map((b) {
      if (b.id == id) {
        return b.copyWith(status: 'Cancelled');
      }
      return b;
    }).toList();
  }
}

final bookingsInteractiveProvider = StateNotifierProvider<BookingsNotifier, List<PrototypeBooking>>((ref) => BookingsNotifier());

// ==========================================
// 4. COMMUNITY / SOCIAL STATE
// ==========================================

class CommunityPost {
  final String id;
  final String author;
  final String authorTitle;
  final String content;
  final String tag;
  final int likes;
  final int shares;
  final List<String> comments;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime date;

  CommunityPost({
    required this.id,
    required this.author,
    required this.authorTitle,
    required this.content,
    required this.tag,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.isLiked,
    required this.isBookmarked,
    required this.date,
  });

  CommunityPost copyWith({
    String? id,
    String? author,
    String? authorTitle,
    String? content,
    String? tag,
    int? likes,
    int? shares,
    List<String>? comments,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? date,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      author: author ?? this.author,
      authorTitle: authorTitle ?? this.authorTitle,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      date: date ?? this.date,
    );
  }
}

class CommunityNotifier extends StateNotifier<List<CommunityPost>> {
  CommunityNotifier() : super([
    CommunityPost(
      id: 'post-1',
      author: 'Markus Chen',
      authorTitle: 'Nexon EV Club',
      content: 'Just finished a 700-km road trip along Western Ghats NH-66. The Fast Charger spacing in Maharashtra/Goa is incredible now. Got average efficiency of 145 Wh/km!',
      tag: 'EV Tech',
      likes: 42,
      shares: 4,
      comments: ['Amazing! Did you charge at Panaji?', 'What was the weather like?'],
      isLiked: false,
      isBookmarked: false,
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CommunityPost(
      id: 'post-2',
      author: 'Sophia Vance',
      authorTitle: 'Himalayan Specialist',
      content: 'Friendly reminder to check chain tension and sprocket wear every 800 km. A loose chain can cause serious transmission damage or slip off!',
      tag: 'Maintenance',
      likes: 18,
      shares: 2,
      comments: ['Good advice, saved me once.', 'Which lube do you recommend?'],
      isLiked: false,
      isBookmarked: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ]);

  void addPost(String author, String content, String tag) {
    final newPost = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      author: author,
      authorTitle: 'Super App Driver',
      content: content,
      tag: tag,
      likes: 0,
      shares: 0,
      comments: [],
      isLiked: false,
      isBookmarked: false,
      date: DateTime.now(),
    );
    state = [newPost, ...state];
  }

  void editPost(String id, String newContent, String newTag) {
    state = state.map((post) {
      if (post.id == id) {
        return post.copyWith(content: newContent, tag: newTag);
      }
      return post;
    }).toList();
  }

  void deletePost(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void toggleLike(String id) {
    state = state.map((p) {
      if (p.id == id) {
        final newLiked = !p.isLiked;
        return p.copyWith(
          isLiked: newLiked,
          likes: newLiked ? p.likes + 1 : p.likes - 1,
        );
      }
      return p;
    }).toList();
  }

  void toggleBookmark(String id) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(isBookmarked: !p.isBookmarked);
      }
      return p;
    }).toList();
  }

  void addComment(String id, String comment) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(comments: [...p.comments, comment]);
      }
      return p;
    }).toList();
  }
}

final communityInteractiveProvider = StateNotifierProvider<CommunityNotifier, List<CommunityPost>>((ref) => CommunityNotifier());

// ==========================================
// 5. AUTO NEWS STATE
// ==========================================

class NewsArticle {
  final String id;
  final String title;
  final String source;
  final String date;
  final String tag;
  final String content;
  final String imageUrl;
  final bool isBookmarked;

  NewsArticle({
    required this.id,
    required this.title,
    required this.source,
    required this.date,
    required this.tag,
    required this.content,
    required this.imageUrl,
    required this.isBookmarked,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? source,
    String? date,
    String? tag,
    String? content,
    String? imageUrl,
    bool? isBookmarked,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      date: date ?? this.date,
      tag: tag ?? this.tag,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class AutoNewsNotifier extends StateNotifier<List<NewsArticle>> {
  AutoNewsNotifier() : super([
    NewsArticle(
      id: 'news-1',
      title: 'Solid-State Batteries to Enter Small Scale Production by 2027',
      source: 'Auto Future Digest',
      date: 'Today',
      tag: 'EV Tech',
      imageUrl: 'https://images.unsplash.com/photo-1558441719-ff34b0524a24',
      content: 'Multiple battery startups have announced pilot manufacturing lanes for solid-state cells designed for electric vehicles. This technology promises double the energy density of current lithium-ion batteries and charge times of under 10 minutes, potentially solving range anxiety forever.',
      isBookmarked: false,
    ),
    NewsArticle(
      id: 'news-2',
      title: 'New Dynamic Toll Rates Planned for Metro Expressways',
      source: 'City Transit Council',
      date: 'Yesterday',
      tag: 'Regulation',
      imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957',
      content: 'Starting next month, expressway toll rates will adjust dynamically based on live traffic densities. City planners aim to reduce bottleneck congestion during peak morning hours by encouraging drivers to schedule trips outside high-density windows.',
      isBookmarked: false,
    ),
    NewsArticle(
      id: 'news-3',
      title: 'Luxury Motorcycles: Trends for the Upcoming Ride Season',
      source: 'Moto World',
      date: '3 days ago',
      tag: 'Design',
      imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87',
      content: 'Motorcycle styling is taking cues from modern cyber-punk aesthetics, featuring carbon fibre paneling, integrated diagnostic head-up displays, and smart ABS traction nodes that link directly to rider helmet telemetry modules.',
      isBookmarked: true,
    ),
  ]);

  void toggleBookmark(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isBookmarked: !n.isBookmarked);
      }
      return n;
    }).toList();
  }
}

final autoNewsInteractiveProvider = StateNotifierProvider<AutoNewsNotifier, List<NewsArticle>>((ref) => AutoNewsNotifier());

// ==========================================
// 6. SHOPPING CART SYSTEM
// ==========================================

class CartItem {
  final String id;
  final String title;
  final double price;
  final IconData icon;
  final int quantity;
  final String category;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
    required this.quantity,
    required this.category,
  });

  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    IconData? icon,
    int? quantity,
    String? category,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(String id, String title, double price, IconData icon, String category) {
    final existingIndex = state.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      state = List<CartItem>.from(state)..[existingIndex] = item.copyWith(quantity: item.quantity + 1);
    } else {
      state = [...state, CartItem(id: id, title: title, price: price, icon: icon, quantity: 1, category: category)];
    }
  }

  void incrementQuantity(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
  }

  void decrementQuantity(String id) {
    state = state.map((item) {
      if (item.id == id && item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartInteractiveProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

class WishlistNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  WishlistNotifier() : super([]);

  void toggleWishlist(String id, String title, double price, IconData icon, String category) {
    final exists = state.any((item) => item['id'] == id);
    if (exists) {
      state = state.where((item) => item['id'] != id).toList();
    } else {
      state = [...state, {'id': id, 'title': title, 'price': price, 'icon': icon, 'category': category}];
    }
  }
}

final wishlistInteractiveProvider = StateNotifierProvider<WishlistNotifier, List<Map<String, dynamic>>>((ref) => WishlistNotifier());
