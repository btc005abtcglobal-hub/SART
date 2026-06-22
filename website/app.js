// ============================================================================
// SART Universal Transport Booking Web Application Controller (app.js)
// ============================================================================

// ----------------------------------------------------------------------------
// 1. STATE INITIALIZATION & LOCALSTORAGE MANAGEMENT
// ----------------------------------------------------------------------------
const DEFAULT_STATE = {
  wallet: {
    balance: 15000.00,
    points: 2450,
    cashback: 350.00,
    transactions: [
      { id: 'tx-001', title: 'Airport Taxi Booking', amount: 800.00, date: new Date(Date.now() - 7200000).toLocaleString(), isCredit: false, category: 'Ride' },
      { id: 'tx-002', title: 'Tire Air Replacement Kit', amount: 3500.00, date: new Date(Date.now() - 86400000).toLocaleString(), isCredit: false, category: 'Store' },
      { id: 'tx-003', title: 'Visa Top-up Loaded', amount: 10000.00, date: new Date(Date.now() - 172800000).toLocaleString(), isCredit: true, category: 'Deposit' }
    ]
  },
  bookings: [
    {
      id: 'bk-001',
      title: 'Tata Nexon EV Rental',
      type: 'rental',
      dateTime: new Date(Date.now() + 172800000).toLocaleString(),
      details: 'Pickup: 10:00 AM • 3 Days Duration',
      status: 'Active',
      cost: 4500.00
    },
    {
      id: 'bk-002',
      title: 'Tire Diagnostics & Balance',
      type: 'mechanic',
      dateTime: new Date(Date.now() - 259200000).toLocaleString(),
      details: 'Assigned: Rajesh Kumar • Completed',
      status: 'Completed',
      cost: 1200.00
    }
  ],
  cart: [],
  wishlist: [],
  notifications: [
    { id: 'notif-1', title: 'Gold Tier Perks Unlocked!', desc: 'Enjoy free airport terminal lounge access & priority dispatch.', read: false, date: 'Today' },
    { id: 'notif-2', title: 'EV Battery Status Optimized', desc: 'Tata Nexon EV charge finished cycle. Ready for commutes.', read: false, date: 'Yesterday' },
    { id: 'notif-3', title: 'Toll Refund Processed', desc: '₹120 refund credited for NH-44 Fastag anomaly.', read: true, date: '3 days ago' }
  ],
  location: "Indiranagar, Bengaluru",
  activeBookingId: null
};

let appState = {};

function loadState() {
  const saved = localStorage.getItem('sart_web_state');
  if (saved) {
    try {
      appState = JSON.parse(saved);
    } catch (e) {
      console.error("Failed to parse localstorage state, loading default.", e);
      appState = JSON.parse(JSON.stringify(DEFAULT_STATE));
    }
  } else {
    appState = JSON.parse(JSON.stringify(DEFAULT_STATE));
  }
}

function saveState() {
  localStorage.setItem('sart_web_state', JSON.stringify(appState));
  updateUI();
}

// ----------------------------------------------------------------------------
// 2. PRODUCT DATABASE & MOCK DATA
// ----------------------------------------------------------------------------
const AUTO_PRODUCTS = [
  {
    id: 'st-001',
    name: 'AI Smart Dash Pro',
    price: 4990.00,
    rating: '4.9',
    icon: 'fa-terminal',
    category: 'Smart Upgrades',
    desc: 'High-fidelity dual-lens dashcam with real-time AI object detection, lane departure warnings, and parking guard telemetry linked straight to your phone.'
  },
  {
    id: 'st-002',
    name: 'OBD2 Diagnostics Scanner',
    price: 1190.00,
    rating: '4.7',
    icon: 'fa-gauge',
    category: 'Diagnostics',
    desc: 'Premium hardware scanner reading real-time engine telemetry, transmission codes, battery capacity status, and emission logs.'
  },
  {
    id: 'st-003',
    name: 'Carbon Fiber Trim Kit',
    price: 2490.00,
    rating: '4.8',
    icon: 'fa-chess-board',
    category: 'Accessories',
    desc: 'Genuine carbon styling wrap with sweat-resistant grips. Snug fit on standard sports dash panels.'
  },
  {
    id: 'st-004',
    name: 'LED Sports Headlamps',
    price: 1890.00,
    rating: '4.6',
    icon: 'fa-lightbulb',
    category: 'Lighting',
    desc: 'High intensity illumination bulbs delivering 200% brighter beams for safer night cruises and highway route previews.'
  }
];

const AUTO_NEWS = [
  { id: 'news-1', title: 'Solid-State Batteries to Enter Small Scale Production by 2027', source: 'Auto Future Digest', date: 'Today', tag: 'EV Tech', desc: 'Multiple battery startups have announced pilot manufacturing lanes for solid-state cells designed for electric vehicles. This technology promises double the energy density of current lithium-ion batteries.' },
  { id: 'news-2', title: 'New Dynamic Toll Rates Planned for Metro Expressways', source: 'City Transit Council', date: 'Yesterday', tag: 'Regulation', desc: 'Starting next month, expressway toll rates will adjust dynamically based on live traffic densities. City planners aim to reduce bottleneck congestion.' },
  { id: 'news-3', title: 'Luxury Yachts: Trends for the Upcoming Sea Ride Season', source: 'Marine World', date: '3 days ago', tag: 'Sea Design', desc: 'Yacht styling is taking cues from modern cyber-punk aesthetics, featuring carbon fibre paneling, integrated diagnostic displays, and smart autopilot systems.' }
];

// Current pricing selections for modals
let activeSelectionPrices = {
  'modal-ride': 800,
  'modal-carrier': 3500,
  'modal-rental': 4500,
  'modal-drivers': 1200,
  'modal-parking': 150,
  'modal-mechanic': 1200,
  'modal-sea': 600,
  'modal-air': 4500,
  'modal-train': 850
};

let activeSelectionTiers = {
  'modal-ride': 'Economy Sedan',
  'modal-carrier': 'Mini Cargo Van',
  'modal-rental': 'Tata Nexon EV',
  'modal-drivers': 'Short Commute Driver',
  'modal-parking': 'Standard Slot',
  'modal-mechanic': 'Diagnostics & Check',
  'modal-sea': 'Ferry Speedliner',
  'modal-air': 'Commercial Economy',
  'modal-train': 'Vande Bharat AC Chair'
};

// ----------------------------------------------------------------------------
// 3. CORE ROUTER & PAGE NAVIGATOR
// ----------------------------------------------------------------------------
let currentTab = 'home';

function switchTab(tabId) {
  currentTab = tabId;
  
  // Update nav UI active class (navbar links)
  document.querySelectorAll('.nav-link').forEach(item => {
    item.classList.remove('active');
  });
  
  const navBtn = document.getElementById(`nav-btn-${tabId}`);
  if (navBtn) navBtn.classList.add('active');
  
  // Hide all screens, show requested screen
  document.querySelectorAll('.tab-screen').forEach(screen => {
    screen.classList.remove('active');
  });
  
  const targetScreen = document.getElementById(`tab-${tabId}`);
  if (targetScreen) targetScreen.classList.add('active');
  
  logActivity(`System`, `Switched active tab section viewport to [${tabId.toUpperCase()}]`);

  // Specific tab initializations
  if (tabId === 'home') {
    // Re-trigger Leaflet map resize
    setTimeout(() => {
      if (leafletMap) {
        leafletMap.invalidateSize();
        recenterMap();
      }
    }, 200);
  } else if (tabId === 'wallet') {
    updateWalletPageDOM();
  }
}

// ----------------------------------------------------------------------------
// 4. LEAFLET MAP & ANIMATED ROUTING SYSTEM
// ----------------------------------------------------------------------------
let leafletMap = null;
let userMarker = null;
let nearbyMarkers = [];
let routingPolyline = null;
let animatedVehicleMarker = null;
let animationIntervalId = null;

const BENGALURU_COORDS = [12.9716, 77.5946];

function initMap() {
  try {
    // Set up Leaflet map
    leafletMap = L.map('explore-map', {
      zoomControl: false,
      attributionControl: false
    }).setView(BENGALURU_COORDS, 14);

    // Stylish dark theme tiles (CartoDB Dark)
    L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
      maxZoom: 19
    }).addTo(leafletMap);

    // Custom pulse icon for user location
    const userPulseIcon = L.divIcon({
      className: 'user-gps-pulse',
      html: `<div style="width: 14px; height: 14px; background: var(--primary); border: 2px solid #fff; border-radius: 50%; box-shadow: 0 0 10px var(--primary); position: relative;">
              <div style="position: absolute; width: 34px; height: 34px; border: 2px solid var(--primary); border-radius: 50%; left: -12px; top: -12px; opacity: 0.5; animation: pulseRed 1.5s infinite alternate;"></div>
             </div>`,
      iconSize: [14, 14],
      iconAnchor: [7, 7]
    });

    userMarker = L.marker(BENGALURU_COORDS, { icon: userPulseIcon }).addTo(leafletMap);
    
    // Generate nearby mock transport vehicles, parking, mechanics
    generateNearbyHotspots();
    
    logActivity(`System`, `Leaflet map engine initialized with Dark Matter tiles`);
  } catch (error) {
    console.error("Map loading error", error);
    logActivity(`Error`, `Could not load map viewport CDN resources.`);
  }
}

function generateNearbyHotspots() {
  if (!leafletMap) return;
  // Clear existing
  nearbyMarkers.forEach(m => leafletMap.removeLayer(m));
  nearbyMarkers = [];

  const icons = {
    taxi: `<i class="fa-solid fa-car" style="color: var(--primary); font-size: 13px;"></i>`,
    rental: `<i class="fa-solid fa-key" style="color: var(--accent); font-size: 12px;"></i>`,
    parking: `<i class="fa-solid fa-square-p" style="color: #8b5cf6; font-size: 13px;"></i>`
  };

  // Generate 8 random points around user coords
  const categories = ['taxi', 'rental', 'parking'];
  for (let i = 0; i < 8; i++) {
    const latOffset = (Math.random() - 0.5) * 0.015;
    const lngOffset = (Math.random() - 0.5) * 0.015;
    const cat = categories[Math.floor(Math.random() * categories.length)];
    
    const lat = BENGALURU_COORDS[0] + latOffset;
    const lng = BENGALURU_COORDS[1] + lngOffset;

    const customIcon = L.divIcon({
      className: 'map-spot-marker',
      html: `<div style="width: 28px; height: 28px; background: var(--panel-bg); border: 1.5px solid var(--card-border); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,0,0,0.5);">
              ${icons[cat]}
             </div>`,
      iconSize: [28, 28],
      iconAnchor: [14, 14]
    });

    const marker = L.marker([lat, lng], { icon: customIcon }).addTo(leafletMap);
    nearbyMarkers.push(marker);
  }
}

function recenterMap() {
  if (leafletMap && userMarker) {
    leafletMap.setView(userMarker.getLatLng(), 14, { animate: true });
    logActivity("System", "Recenter GPS viewport");
  }
}

function zoomInMap() {
  if (leafletMap) leafletMap.zoomIn();
}
function zoomOutMap() {
  if (leafletMap) leafletMap.zoomOut();
}

function toggleMapHotspots() {
  generateNearbyHotspots();
  logActivity(`System`, `Refreshed nearby drivers & charging nodes on map`);
}

// Animated trip route visualizer
function animateActiveBookingRoute(bookingTitle, type) {
  if (!leafletMap) return;

  // Clear existing routing
  if (routingPolyline) leafletMap.removeLayer(routingPolyline);
  if (animatedVehicleMarker) leafletMap.removeLayer(animatedVehicleMarker);
  if (animationIntervalId) clearInterval(animationIntervalId);

  // Define route endpoint
  const start = BENGALURU_COORDS;
  let end = [start[0] + 0.012, start[1] + 0.018];
  
  if (type === 'sea') {
    end = [start[0] - 0.02, start[1] - 0.01];
  } else if (type === 'air') {
    end = [start[0] + 0.035, start[1] + 0.025];
  } else if (type === 'train') {
    end = [start[0] - 0.015, start[1] + 0.03];
  }

  // Draw Route Polyline
  const routePoints = [start];
  
  const segments = 10;
  for (let i = 1; i < segments; i++) {
    const ratio = i / segments;
    const intermediateLat = start[0] + (end[0] - start[0]) * ratio + (Math.random() - 0.5) * 0.002;
    const intermediateLng = start[1] + (end[1] - start[1]) * ratio + (Math.random() - 0.5) * 0.002;
    routePoints.push([intermediateLat, intermediateLng]);
  }
  routePoints.push(end);

  routingPolyline = L.polyline(routePoints, {
    color: 'var(--primary)',
    weight: 4,
    opacity: 0.7,
    dashArray: '8, 8',
    lineJoin: 'round'
  }).addTo(leafletMap);

  leafletMap.fitBounds(routingPolyline.getBounds(), { padding: [40, 40] });

  let vehicleIconClass = 'fa-car-side';
  let vehicleColor = 'var(--primary)';
  if (type === 'sea') { vehicleIconClass = 'fa-ship'; vehicleColor = 'var(--success)'; }
  else if (type === 'air') { vehicleIconClass = 'fa-plane'; vehicleColor = 'var(--warning)'; }
  else if (type === 'train') { vehicleIconClass = 'fa-train'; vehicleColor = '#c864ff'; }

  const animIcon = L.divIcon({
    className: 'moving-car-icon',
    html: `<div style="width: 32px; height: 32px; background: ${vehicleColor}; border: 2px solid #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 10px ${vehicleColor};">
            <i class="fa-solid ${vehicleIconClass}" style="color: #fff; font-size: 14px;"></i>
           </div>`,
    iconSize: [32, 32],
    iconAnchor: [16, 16]
  });

  animatedVehicleMarker = L.marker(start, { icon: animIcon }).addTo(leafletMap);

  let currentStep = 0;
  animationIntervalId = setInterval(() => {
    if (currentStep >= routePoints.length) {
      currentStep = 0;
    }
    const nextCoords = routePoints[currentStep];
    animatedVehicleMarker.setLatLng(nextCoords);
    
    const bookingCardDesc = document.getElementById('map-active-booking-desc');
    if (bookingCardDesc) {
      if (currentStep === 0) {
        bookingCardDesc.innerText = "Transit starting • Live Tracking";
      } else if (currentStep === routePoints.length - 1) {
        bookingCardDesc.innerText = "Arrived! Trip completed.";
        logActivity(`Bookings`, `Live active trip [${bookingTitle}] has completed.`);
        clearInterval(animationIntervalId);
      } else {
        const percent = Math.round((currentStep / (routePoints.length - 1)) * 100);
        bookingCardDesc.innerText = `In Transit • ${percent}% completed`;
      }
    }

    currentStep++;
  }, 1800);
}

function clearMapRoutingAnimation() {
  if (routingPolyline && leafletMap) leafletMap.removeLayer(routingPolyline);
  if (animatedVehicleMarker && leafletMap) leafletMap.removeLayer(animatedVehicleMarker);
  if (animationIntervalId) clearInterval(animationIntervalId);
  
  routingPolyline = null;
  animatedVehicleMarker = null;
}

// ----------------------------------------------------------------------------
// 5. MODAL LOGIC & ACTIONS
// ----------------------------------------------------------------------------
function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.add('open');
    logActivity(`System`, `Opened panel [${modalId.replace('modal-', '').toUpperCase()}]`);
  }
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.remove('open');
  }
}

function selectBookingOption(element, groupName, priceStr) {
  const parent = element.parentElement;
  parent.querySelectorAll('.option-select-card').forEach(card => {
    card.classList.remove('selected');
  });
  
  element.classList.add('selected');
  
  let modalWrapper = element;
  while (modalWrapper && !modalWrapper.classList.contains('modal-overlay')) {
    modalWrapper = modalWrapper.parentElement;
  }
  
  if (modalWrapper) {
    const modalId = modalWrapper.id;
    activeSelectionPrices[modalId] = parseFloat(priceStr);
    activeSelectionTiers[modalId] = element.getAttribute('data-val');
    
    logActivity(`Input`, `Selected tier: ${activeSelectionTiers[modalId]} (₹${priceStr})`);
  }
}

// ----------------------------------------------------------------------------
// 6. DETAILED BOOKING MODULE SUBMISSIONS
// ----------------------------------------------------------------------------
function executeGenericBooking(type, title, details, cost, metadata = {}) {
  if (appState.wallet.balance < cost) {
    alert(`Insufficient balance in SART Wallet!\nRequired: ₹${cost.toFixed(2)}\nAvailable: ₹${appState.wallet.balance.toFixed(2)}`);
    logActivity(`Error`, `Transaction failed: Insufficient funds for booking ${title}`);
    return false;
  }

  appState.wallet.balance -= cost;
  const pointsEarned = Math.floor(cost * 0.5);
  appState.wallet.points += pointsEarned;
  
  const tx = {
    id: `tx-${Date.now()}`,
    title: `${title} Payment`,
    amount: cost,
    date: new Date().toLocaleString(),
    isCredit: false,
    category: type.toUpperCase()
  };
  appState.wallet.transactions.unshift(tx);

  const newBookingId = `bk-${Date.now()}`;
  const newBooking = {
    id: newBookingId,
    title: title,
    type: type,
    dateTime: new Date(Date.now() + 86400000).toLocaleString(),
    details: details,
    status: 'Active',
    cost: cost,
    meta: metadata
  };
  appState.bookings.unshift(newBooking);
  appState.activeBookingId = newBookingId;

  logActivity(`Wallet`, `Charged ₹${cost.toFixed(2)} for ${title}. Gained +${pointsEarned} loyalty points.`);
  logActivity(`Bookings`, `Added active booking: ${details}`);
  
  saveState();
  
  // Set Map active booking text
  document.getElementById('map-active-booking-title').innerText = title;
  document.getElementById('map-active-booking-desc').innerText = `Scheduled trip active. Coordinates loading...`;
  document.getElementById('map-active-booking-card').style.display = 'block';
  
  let mapIconClass = 'fa-car-side';
  if (type === 'sea') mapIconClass = 'fa-ship';
  else if (type === 'air') mapIconClass = 'fa-plane';
  else if (type === 'train') mapIconClass = 'fa-train';
  document.getElementById('map-active-booking-icon').className = `fa-solid ${mapIconClass}`;

  const activeModal = document.querySelector('.modal-overlay.open');
  if (activeModal) closeModal(activeModal.id);

  setTimeout(() => {
    alert(`🎉 Ticket Booked Successfully!\n\n${title}\nDetails: ${details}\nCharged: ₹${cost.toFixed(2)}\n\nYour active ride is now live-tracked on the map!`);
    switchTab('home');
    document.querySelector('.web-main-content').scrollTop = 0; // scroll map into view
    animateActiveBookingRoute(title, type);
  }, 350);

  return true;
}

// Bindings
function submitRoadRideBooking() {
  const from = document.getElementById('ride-from').value;
  const to = document.getElementById('ride-to').value;
  const cost = activeSelectionPrices['modal-ride'];
  const tier = activeSelectionTiers['modal-ride'];
  executeGenericBooking('ride', `Ride: ${from} to ${to}`, `${tier} • Premium Chauffeur`, cost, { from, to });
}

function submitCarrierBooking() {
  const from = document.getElementById('carrier-from').value;
  const to = document.getElementById('carrier-to').value;
  const cost = activeSelectionPrices['modal-carrier'];
  const tier = activeSelectionTiers['modal-carrier'];
  executeGenericBooking('carrier', `Carrier: ${from} to ${to}`, `${tier} • Logistics Cargo`, cost, { from, to });
}

function submitRentalBooking() {
  const days = document.getElementById('rental-days').value;
  const costPerDay = activeSelectionPrices['modal-rental'];
  const tier = activeSelectionTiers['modal-rental'];
  const totalCost = costPerDay * parseInt(days);
  executeGenericBooking('rental', `${tier} Rental`, `Duration: ${days} Days • Self-Drive`, totalCost, { days });
}

function submitDriverBooking() {
  const pickup = document.getElementById('driver-pickup').value;
  const cost = activeSelectionPrices['modal-drivers'];
  const tier = activeSelectionTiers['modal-drivers'];
  executeGenericBooking('drivers', `Driver Hire`, `Period: ${tier} • Pickup: ${pickup}`, cost, { pickup });
}

function submitParkingBooking() {
  const zone = document.getElementById('parking-zone').value;
  const cost = activeSelectionPrices['modal-parking'];
  const tier = activeSelectionTiers['modal-parking'];
  executeGenericBooking('parking', `Reserved Slot: ${zone}`, `${tier} • Allocated`, cost, { zone });
}

function submitMechanicBooking() {
  const issue = document.getElementById('mech-issue').value;
  const cost = activeSelectionPrices['modal-mechanic'];
  const tier = activeSelectionTiers['modal-mechanic'];
  executeGenericBooking('mechanic', `Mechanic visit`, `Diagnosis: ${tier} • Issue: ${issue.substring(0, 25)}...`, cost, { issue });
}

function submitSeaBooking() {
  const from = document.getElementById('sea-from').value;
  const to = document.getElementById('sea-to').value;
  const cost = activeSelectionPrices['modal-sea'];
  const tier = activeSelectionTiers['modal-sea'];
  executeGenericBooking('sea', `Sea Voyage: ${from} to ${to}`, `Vessel: ${tier} • Maritime Boarding`, cost, { from, to });
}

function submitAirBooking() {
  const from = document.getElementById('air-from').value;
  const to = document.getElementById('air-to').value;
  const cost = activeSelectionPrices['modal-air'];
  const tier = activeSelectionTiers['modal-air'];
  executeGenericBooking('air', `Air Transit: ${from} to ${to}`, `Flight: ${tier} • Cabin Clearance`, cost, { from, to });
}

function submitTrainBooking() {
  const from = document.getElementById('train-from').value;
  const to = document.getElementById('train-to').value;
  const cost = activeSelectionPrices['modal-train'];
  const tier = activeSelectionTiers['modal-train'];
  executeGenericBooking('train', `Train Journey: ${from} to ${to}`, `Express: ${tier} • Platform Departure`, cost, { from, to });
}

// ----------------------------------------------------------------------------
// 7. WALLET SCREEN FUNCTIONS
// ----------------------------------------------------------------------------
function toggleWalletForm(formType) {
  const dep = document.getElementById('wallet-deposit-form');
  const trsf = document.getElementById('wallet-transfer-form');
  if (formType === 'deposit') {
    dep.style.display = dep.style.display === 'none' ? 'block' : 'none';
    trsf.style.display = 'none';
  } else {
    trsf.style.display = trsf.style.display === 'none' ? 'block' : 'none';
    dep.style.display = 'none';
  }
}

function executeWalletDeposit() {
  const amount = parseFloat(document.getElementById('deposit-amount').value);
  const source = document.getElementById('deposit-source').value;
  
  if (isNaN(amount) || amount <= 0) {
    alert("Please enter a valid deposit amount.");
    return;
  }

  appState.wallet.balance += amount;
  const pointsEarned = Math.floor(amount * 0.5);
  appState.wallet.points += pointsEarned;

  const tx = {
    id: `tx-${Date.now()}`,
    title: `Top-up via ${source}`,
    amount: amount,
    date: new Date().toLocaleString(),
    isCredit: true,
    category: 'Deposit'
  };
  appState.wallet.transactions.unshift(tx);

  logActivity(`Wallet`, `Loaded ₹${amount.toFixed(2)} from ${source}.`);
  saveState();
  
  document.getElementById('wallet-deposit-form').style.display = 'none';
  alert(`₹${amount.toFixed(2)} Loaded Successfully!`);
}

function executeWalletTransfer() {
  const recipient = document.getElementById('transfer-recipient').value;
  const amount = parseFloat(document.getElementById('transfer-amount').value);

  if (isNaN(amount) || amount <= 0) {
    alert("Please enter a valid transfer amount.");
    return;
  }
  if (!recipient.trim()) {
    alert("Please enter recipient account details.");
    return;
  }

  if (appState.wallet.balance < amount) {
    alert("Insufficient balance for this transfer.");
    return;
  }

  appState.wallet.balance -= amount;
  
  const tx = {
    id: `tx-${Date.now()}`,
    title: `Transfer to ${recipient}`,
    amount: amount,
    date: new Date().toLocaleString(),
    isCredit: false,
    category: 'Transfer'
  };
  appState.wallet.transactions.unshift(tx);

  logActivity(`Wallet`, `Transferred ₹${amount.toFixed(2)} to ${recipient}.`);
  saveState();
  
  document.getElementById('wallet-transfer-form').style.display = 'none';
  alert(`₹${amount.toFixed(2)} transferred successfully.`);
}

function claimCashbackMoney() {
  const cash = appState.wallet.cashback;
  if (cash <= 0) {
    alert("No cashback balance available.");
    return;
  }

  appState.wallet.balance += cash;
  appState.wallet.cashback = 0.0;

  const tx = {
    id: `tx-${Date.now()}`,
    title: `Redeemed Cashback Reward`,
    amount: cash,
    date: new Date().toLocaleString(),
    isCredit: true,
    category: 'Deposit'
  };
  appState.wallet.transactions.unshift(tx);

  logActivity(`Wallet`, `Redeemed cashback ₹${cash.toFixed(2)}`);
  saveState();
  alert(`₹${cash.toFixed(2)} cashback claimed!`);
}

// ----------------------------------------------------------------------------
// 8. AUTO STORE & SHOPPING CART FUNCTIONS
// ----------------------------------------------------------------------------
let currentStoreSearchQuery = '';

function renderStoreProducts() {
  const grid = document.getElementById('products-grid-container');
  if (!grid) return;
  grid.innerHTML = '';

  const filtered = AUTO_PRODUCTS.filter(p => {
    return p.name.toLowerCase().includes(currentStoreSearchQuery.toLowerCase()) ||
           p.category.toLowerCase().includes(currentStoreSearchQuery.toLowerCase());
  });

  if (filtered.length === 0) {
    grid.innerHTML = `<div style="grid-column: span 3; text-align: center; color: var(--text-secondary); padding: 20px;">No matching accessories found.</div>`;
    return;
  }

  filtered.forEach(p => {
    const isWished = appState.wishlist.includes(p.id);
    const wishClass = isWished ? 'active' : '';
    const wishIcon = isWished ? 'fa-solid fa-heart' : 'fa-regular fa-heart';

    grid.innerHTML += `
      <div class="product-card">
        <div class="product-img-panel">
          <i class="fa-solid ${p.icon}"></i>
          <div class="product-wish-btn ${wishClass}" onclick="toggleWishlistProduct('${p.id}')">
            <i class="${wishIcon}"></i>
          </div>
        </div>
        <div class="product-details">
          <span class="product-cat">${p.category}</span>
          <div class="product-name">${p.name}</div>
          <div class="product-price-row">
            <span class="product-price">₹${p.price.toFixed(0)}</span>
            <div class="product-add-btn" onclick="addToCart('${p.id}')">
              <i class="fa-solid fa-plus"></i>
            </div>
          </div>
        </div>
      </div>
    `;
  });
}

function filterStoreProducts() {
  const query = document.getElementById('store-search').value;
  currentStoreSearchQuery = query;
  renderStoreProducts();
}

function addToCart(productId) {
  const prod = AUTO_PRODUCTS.find(p => p.id === productId);
  if (!prod) return;

  const existing = appState.cart.find(item => item.id === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    appState.cart.push({
      id: prod.id,
      name: prod.name,
      price: prod.price,
      icon: prod.icon,
      quantity: 1,
      category: prod.category
    });
  }

  logActivity(`Store`, `Added item [${prod.name}] to shopping cart.`);
  saveState();
  showToastNotification(`Added to Cart: ${prod.name}`);
}

function toggleWishlistProduct(productId) {
  const index = appState.wishlist.indexOf(productId);
  if (index >= 0) {
    appState.wishlist.splice(index, 1);
  } else {
    appState.wishlist.push(productId);
  }
  saveState();
}

function updateCartDOM() {
  const container = document.getElementById('cart-items-container');
  const totalTxt = document.getElementById('cart-total-txt');
  if (!container) return;

  container.innerHTML = '';
  
  if (appState.cart.length === 0) {
    container.innerHTML = `<div style="text-align: center; color: var(--text-secondary); padding: 30px 10px; font-size:12px;">Your shopping cart is currently empty.</div>`;
    totalTxt.innerText = `₹0.00`;
    document.getElementById('cart-checkout-btn').disabled = true;
    return;
  }

  let total = 0;
  appState.cart.forEach(item => {
    total += item.price * item.quantity;
    container.innerHTML += `
      <div class="cart-item-row">
        <div class="cart-item-details">
          <i class="fa-solid ${item.icon}"></i>
          <div class="cart-item-name">
            <h4>${item.name}</h4>
            <p>₹${item.price.toFixed(2)} each</p>
          </div>
        </div>
        <div class="cart-item-qty">
          <div class="cart-qty-btn" onclick="adjustCartQty('${item.id}', -1)"><i class="fa-solid fa-minus"></i></div>
          <span>${item.quantity}</span>
          <div class="cart-qty-btn" onclick="adjustCartQty('${item.id}', 1)"><i class="fa-solid fa-plus"></i></div>
          <div class="cart-item-delete" onclick="removeCartItem('${item.id}')"><i class="fa-solid fa-trash-can"></i></div>
        </div>
      </div>
    `;
  });

  totalTxt.innerText = `₹${total.toFixed(2)}`;
  document.getElementById('cart-checkout-btn').disabled = false;
}

function adjustCartQty(itemId, amount) {
  const item = appState.cart.find(i => i.id === itemId);
  if (!item) return;

  item.quantity += amount;
  if (item.quantity <= 0) {
    removeCartItem(itemId);
  } else {
    saveState();
  }
}

function removeCartItem(itemId) {
  appState.cart = appState.cart.filter(i => i.id !== itemId);
  saveState();
  logActivity(`Store`, `Removed product ID [${itemId}] from cart.`);
}

function executeCartCheckout() {
  let total = 0;
  appState.cart.forEach(item => {
    total += item.price * item.quantity;
  });

  if (appState.wallet.balance < total) {
    alert(`Insufficient balance!\nRequired: ₹${total.toFixed(2)}\nAvailable: ₹${appState.wallet.balance.toFixed(2)}`);
    return;
  }

  appState.wallet.balance -= total;
  
  appState.cart.forEach(item => {
    const tx = {
      id: `tx-${Date.now()}-${item.id}`,
      title: `Checkout: Ordered ${item.name}`,
      amount: item.price * item.quantity,
      date: new Date().toLocaleString(),
      isCredit: false,
      category: 'STORE'
    };
    appState.wallet.transactions.unshift(tx);

    const b = {
      id: `bk-${Date.now()}-${item.id}`,
      title: `Ordered: ${item.name}`,
      type: 'carrier',
      dateTime: new Date().toLocaleString(),
      details: `Shipping status: Processing dispatch`,
      status: 'Active',
      cost: item.price * item.quantity
    };
    appState.bookings.unshift(b);
  });

  logActivity(`Wallet`, `Charged ₹${total.toFixed(2)} for shopping cart checkout.`);
  
  appState.cart = [];
  saveState();
  
  alert(`🛒 Purchase Completed!\nYour accessories order has been paid. You can track carrier delivery status under Bookings.`);
}

// ----------------------------------------------------------------------------
// 9. BOOKING REGISTRY / RECEIPT HISTORY MANAGEMENT
// ----------------------------------------------------------------------------
let currentRegistryFilter = 'All';

function renderBookingsRegistry() {
  const container = document.getElementById('registry-bookings-container');
  if (!container) return;

  container.innerHTML = '';

  const filtered = appState.bookings.filter(b => {
    if (currentRegistryFilter === 'Active') return b.status === 'Active';
    if (currentRegistryFilter === 'Completed') return b.status === 'Completed';
    if (currentRegistryFilter === 'Cancelled') return b.status === 'Cancelled';
    return true;
  });

  if (filtered.length === 0) {
    container.innerHTML = `<div style="text-align: center; color: var(--text-secondary); padding: 40px 10px; font-size:12px;">No bookings matching "${currentRegistryFilter}" found.</div>`;
    return;
  }

  const icons = {
    ride: 'fa-car',
    carrier: 'fa-truck',
    rental: 'fa-key',
    drivers: 'fa-user-tie',
    parking: 'fa-square-p',
    mechanic: 'fa-screwdriver-wrench',
    sea: 'fa-ship',
    air: 'fa-plane',
    train: 'fa-train'
  };

  filtered.forEach(b => {
    const isCancelled = b.status === 'Cancelled';
    const isCompleted = b.status === 'Completed';
    
    let statusClass = 'active';
    if (isCancelled) statusClass = 'cancelled';
    else if (isCompleted) statusClass = 'completed';

    const iconClass = icons[b.type] || 'fa-receipt';

    container.innerHTML += `
      <div class="booking-card" onclick="openBookingInvoice('${b.id}')">
        <div class="booking-card-left">
          <div class="booking-card-icon ${b.type || 'other'}">
            <i class="fa-solid ${iconClass}"></i>
          </div>
          <div class="booking-card-text">
            <h4 style="${isCancelled ? 'text-decoration: line-through;' : ''}">${b.title}</h4>
            <p>${b.details}</p>
          </div>
        </div>
        <div class="booking-card-right">
          <div class="booking-card-price" style="${isCancelled ? 'color: var(--text-secondary);' : ''}">₹${b.cost.toFixed(0)}</div>
          <div class="booking-card-status ${statusClass}">${b.status}</div>
        </div>
      </div>
    `;
  });
}

function filterBookingsRegistry(filter, element) {
  currentRegistryFilter = filter;
  
  element.parentElement.querySelectorAll('.booking-tab').forEach(tab => {
    tab.classList.remove('active');
  });
  element.classList.add('active');

  renderBookingsRegistry();
}

let activeViewingInvoiceId = null;

function openBookingInvoice(bookingId) {
  const b = appState.bookings.find(item => item.id === bookingId);
  if (!b) return;

  activeViewingInvoiceId = bookingId;
  const body = document.getElementById('receipt-invoice-body');
  
  body.innerHTML = `
    <div class="receipt-row" style="margin-top: 10px;">
      <span class="receipt-label">Invoice Reference:</span>
      <span class="receipt-val" style="font-family: monospace;">${b.id}</span>
    </div>
    <div class="receipt-row">
      <span class="receipt-label">Booking Item:</span>
      <span class="receipt-val">${b.title}</span>
    </div>
    <div class="receipt-row">
      <span class="receipt-label">Category Sector:</span>
      <span class="receipt-val" style="text-transform: uppercase; color: var(--secondary); font-weight: bold;">${b.type}</span>
    </div>
    <hr style="border: 0; border-top: 1px solid var(--dark-border); margin: 12px 0;">
    <div class="receipt-row">
      <span class="receipt-label">Scheduled Time:</span>
      <span class="receipt-val">${b.dateTime}</span>
    </div>
    <div class="receipt-row">
      <span class="receipt-label">Service Details:</span>
      <span class="receipt-val">${b.details}</span>
    </div>
    <div class="receipt-row">
      <span class="receipt-label">Booking Status:</span>
      <span class="receipt-val" style="font-weight: 800; color: ${b.status === 'Cancelled' ? 'var(--error)' : 'var(--success)'};">${b.status}</span>
    </div>
    <hr style="border: 0; border-top: 1px solid var(--dark-border); margin: 12px 0;">
    <div class="receipt-row" style="margin-bottom: 20px;">
      <span class="receipt-label" style="font-size: 14px; font-weight: bold;">Grand Charges Paid:</span>
      <span class="receipt-val receipt-total">₹${b.cost.toFixed(2)}</span>
    </div>
  `;

  const cancelBtn = document.getElementById('receipt-cancel-btn');
  if (b.status === 'Active') {
    cancelBtn.style.display = 'block';
  } else {
    cancelBtn.style.display = 'none';
  }

  closeModal('modal-bookings-registry');
  openModal('modal-booking-receipt');
}

function executeBookingCancel() {
  if (!activeViewingInvoiceId) return;
  const b = appState.bookings.find(item => item.id === activeViewingInvoiceId);
  if (!b) return;

  if (confirm(`Confirm Cancellation?\n\nAre you sure you want to cancel "${b.title}"? A refund of ₹${b.cost.toFixed(2)} will be credited back to your SART wallet.`)) {
    appState.wallet.balance += b.cost;
    
    const tx = {
      id: `tx-${Date.now()}`,
      title: `Refund: Cancelled ${b.title}`,
      amount: b.cost,
      date: new Date().toLocaleString(),
      isCredit: true,
      category: 'REFUND'
    };
    appState.wallet.transactions.unshift(tx);

    b.status = 'Cancelled';
    
    if (appState.activeBookingId === b.id) {
      appState.activeBookingId = null;
      document.getElementById('map-active-booking-card').style.display = 'none';
      clearMapRoutingAnimation();
    }

    logActivity(`Wallet`, `Refunded ₹${b.cost.toFixed(2)} for ${b.id}`);
    logActivity(`Bookings`, `Cancelled reference [${b.id}]`);
    
    saveState();
    closeModal('modal-booking-receipt');
    
    alert(`Cancellation confirmed! Refund of ₹${b.cost.toFixed(2)} has been credited.`);
    openModal('modal-bookings-registry');
  }
}

// ----------------------------------------------------------------------------
// 10. NOTIFICATIONS MODULE
// ----------------------------------------------------------------------------
function renderNotifications() {
  const container = document.getElementById('notifications-container');
  const badge = document.getElementById('notif-badge');
  if (!container) return;

  container.innerHTML = '';
  
  const unreadList = appState.notifications.filter(n => !n.read);
  if (unreadList.length > 0) {
    badge.style.display = 'flex';
    badge.innerText = unreadList.length;
  } else {
    badge.style.display = 'none';
  }

  appState.notifications.forEach(n => {
    container.innerHTML += `
      <div style="background: rgba(255,255,255,0.02); border: 1px solid ${n.read ? 'var(--card-border)' : 'var(--primary)'}; border-radius: 16px; padding: 12px; position: relative; cursor: pointer;" onclick="markNotificationRead('${n.id}')">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <h4 style="font-size: 12.5px; font-weight: bold; display: flex; align-items: center; gap: 6px;">
            ${!n.read ? '<span style="width: 6px; height: 6px; background: var(--primary); border-radius: 50%;"></span>' : ''}
            ${n.title}
          </h4>
          <span style="font-size: 9.5px; color: var(--text-secondary);">${n.date}</span>
        </div>
        <p style="font-size: 11.5px; color: var(--text-secondary); line-height: 1.4;">${n.desc}</p>
      </div>
    `;
  });
}

function markNotificationRead(notifId) {
  const n = appState.notifications.find(item => item.id === notifId);
  if (n && !n.read) {
    n.read = true;
    saveState();
  }
}

// ----------------------------------------------------------------------------
// 11. PORTAL SMART SEARCH
// ----------------------------------------------------------------------------
function executePortalSearch() {
  const query = document.getElementById('portal-search-input').value.toLowerCase();
  const resultsContainer = document.getElementById('portal-search-results');
  if (!resultsContainer) return;

  resultsContainer.innerHTML = '';
  if (!query.trim()) {
    resultsContainer.innerHTML = `<div style="text-align: center; color: var(--text-secondary); padding: 10px; font-size:12px;">Type keywords above to search SART database...</div>`;
    return;
  }

  const searchOptions = [
    { title: 'Road Ride Booking', kw: ['ride', 'taxi', 'car', 'cab', 'economy', 'suv'], modal: 'modal-ride', icon: 'fa-car', color: 'var(--primary)' },
    { title: 'Logistics Cargo Truck', kw: ['carrier', 'truck', 'logistics', 'delivery', 'cargo'], modal: 'modal-carrier', icon: 'fa-truck', color: 'var(--secondary)' },
    { title: 'Hourly Vehicle Rental', kw: ['rental', 'key', 'nexon', 'himalayan', 'bike', 'motorcycle'], modal: 'modal-rental', icon: 'fa-key', color: 'var(--accent)' },
    { title: 'Personal Chauffeur Hire', kw: ['driver', 'chauffeur', 'verified'], modal: 'modal-drivers', icon: 'fa-user-tie', color: 'var(--warning)' },
    { title: 'Shared Parking Spot', kw: ['parking', 'slot', 'ev slot'], modal: 'modal-parking', icon: 'fa-square-p', color: '#8b5cf6' },
    { title: 'Mechanic Diagnostic Visit', kw: ['mechanic', 'repair', 'wheel', 'overhaul'], modal: 'modal-mechanic', icon: 'fa-screwdriver-wrench', color: '#64748b' },
    { title: 'Ferry & Yacht Sea Booking', kw: ['sea', 'ferry', 'yacht', 'maritime', 'boat', 'water'], modal: 'modal-sea', icon: 'fa-ship', color: 'var(--success)' },
    { title: 'Flight & Heli Air Booking', kw: ['air', 'flight', 'helicopter', 'chopper', 'plane', 'sky'], modal: 'modal-air', icon: 'fa-plane', color: 'var(--warning)' },
    { title: 'Train Vande Bharat Book', kw: ['train', 'express', 'metro', 'railway', 'vande', 'rajdhani'], modal: 'modal-train', icon: 'fa-train', color: '#c864ff' }
  ];

  const matched = searchOptions.filter(opt => {
    return opt.title.toLowerCase().includes(query) || opt.kw.some(k => k.includes(query));
  });

  if (matched.length === 0) {
    resultsContainer.innerHTML = `<div style="text-align: center; color: var(--text-secondary); padding: 15px; font-size:12px;">No matching modules found in directory.</div>`;
    return;
  }

  matched.forEach(opt => {
    resultsContainer.innerHTML += `
      <div class="booking-card" onclick="closeModal('modal-search'); openModal('${opt.modal}')">
        <div class="booking-card-left">
          <div style="width: 32px; height: 32px; border-radius: 50%; background: rgba(255,255,255,0.05); display: flex; align-items: center; justify-content: center; color: ${opt.color};">
            <i class="fa-solid ${opt.icon}"></i>
          </div>
          <div class="booking-card-text">
            <h4>${opt.title}</h4>
            <p style="font-size: 9px; text-transform: uppercase;">Shortcut trigger</p>
          </div>
        </div>
        <i class="fa-solid fa-chevron-right" style="font-size: 10px; color: var(--text-secondary);"></i>
      </div>
    `;
  });
}

// ----------------------------------------------------------------------------
// 12. SOS EMERGENCY BROADCAST ALARM
// ----------------------------------------------------------------------------
let sosSeconds = 5;
let sosIntervalId = null;

function triggerImmediateSOS() {
  sosSeconds = 5;
  document.getElementById('sos-counter-number').innerText = sosSeconds;
  
  openModal('modal-sos-countdown');
  
  if (sosIntervalId) clearInterval(sosIntervalId);
  logActivity(`SOS`, `Triggered SOS emergency countdown...`);
  
  sosIntervalId = setInterval(() => {
    sosSeconds--;
    document.getElementById('sos-counter-number').innerText = sosSeconds;
    
    if (sosSeconds <= 0) {
      clearInterval(sosIntervalId);
      executeImmediateSosBroadcasting();
    }
  }, 1000);
}

function stopSosCountdown() {
  if (sosIntervalId) {
    clearInterval(sosIntervalId);
    sosIntervalId = null;
  }
  logActivity(`SOS`, `SOS emergency aborted.`);
}

function executeImmediateSosBroadcasting() {
  if (sosIntervalId) clearInterval(sosIntervalId);
  sosIntervalId = null;
  
  closeModal('modal-sos-countdown');
  logActivity(`SOS`, `Emergency SOS active! Coordinates ${BENGALURU_COORDS.toString()} broadcast to local emergency responders.`);
  alert("🚨 Emergency SOS Activated!\n\nCoordinates sent. Assistance is on the way!");
}

// ----------------------------------------------------------------------------
// 13. DYNAMIC PROFILE SUB-PAGES
// ----------------------------------------------------------------------------
function openProfileSubpage(featureId, title) {
  document.getElementById('subpage-title-txt').innerText = title;
  const container = document.getElementById('subpage-content-container');
  container.innerHTML = '';

  let htmlContent = '';
  
  if (featureId === 'documents') {
    htmlContent = `
      <div style="display: flex; flex-direction: column; gap: 14px;">
        <h4 style="color: var(--primary);"><i class="fa-solid fa-id-card"></i> Digilocker Integration</h4>
        <p style="font-size: 12px; color: var(--text-secondary); line-height: 1.4;">Verify your identity files to unlock high-speed premium vehicle rentals.</p>
        
        <div style="display:flex; justify-content:space-between; align-items:center; border: 1px solid var(--dark-border); padding: 12px; border-radius: 12px; background: rgba(0,0,0,0.2);">
          <div>
            <div style="font-size:12.5px; font-weight:bold;">Driving License</div>
            <div style="font-size:10px; color:var(--success);">Verified (Valid till 2038)</div>
          </div>
          <i class="fa-solid fa-circle-check" style="color:var(--success);"></i>
        </div>
        
        <div style="display:flex; justify-content:space-between; align-items:center; border: 1px solid var(--dark-border); padding: 12px; border-radius: 12px; background: rgba(0,0,0,0.2);">
          <div>
            <div style="font-size:12.5px; font-weight:bold;">Vehicle RC Permit</div>
            <div style="font-size:10px; color:var(--success);">KA-03-MY-8820 Verified</div>
          </div>
          <i class="fa-solid fa-circle-check" style="color:var(--success);"></i>
        </div>
        
        <button class="action-btn" style="padding: 10px; font-size:12px; align-self: flex-start;" onclick="alert('Upload system offline in demo mode.')">Upload New Documents</button>
      </div>
    `;
  } else if (featureId === 'payment') {
    htmlContent = `
      <div style="display: flex; flex-direction: column; gap: 12px;">
        <h4><i class="fa-solid fa-credit-card"></i> Linked Payment Cards</h4>
        
        <div style="display:flex; gap:12px; align-items:center; border: 1px solid var(--dark-border); padding: 12px; border-radius: 12px;">
          <i class="fa-brands fa-cc-visa" style="font-size:24px; color:#1a1f71;"></i>
          <div>
            <div style="font-size:12.5px; font-weight:bold;">Visa Personal Classic</div>
            <div style="font-size:10px; color:var(--text-secondary);">•••• •••• •••• 4242 | Expiry 12/28</div>
          </div>
        </div>

        <div style="display:flex; gap:12px; align-items:center; border: 1px solid var(--dark-border); padding: 12px; border-radius: 12px;">
          <i class="fa-brands fa-cc-mastercard" style="font-size:24px; color:#eb001b;"></i>
          <div>
            <div style="font-size:12.5px; font-weight:bold;">Mastercard Gold Business</div>
            <div style="font-size:10px; color:var(--text-secondary);">•••• •••• •••• 8839 | Expiry 09/27</div>
          </div>
        </div>

        <button class="action-btn" style="padding: 10px; font-size:12px; align-self: flex-start;" onclick="alert('Adding cards restricted in front-end demo.')">Link UPI / Debit Card</button>
      </div>
    `;
  } else {
    htmlContent = `
      <div>
        <h4>${title} Configurations</h4>
        <p style="font-size:12px; color:var(--text-secondary); margin-top: 10px; line-height: 1.5;">
          This subpage controls parameters related to ${title.toLowerCase()}. Settings saved to session storage.
        </p>
        <div class="form-group" style="margin-top: 16px;">
          <label>Toggle Active status</label>
          <select class="input-field select-field" style="width: 200px;">
            <option value="1">Enabled / On</option>
            <option value="0">Disabled / Off</option>
          </select>
        </div>
        <button class="action-btn" style="padding: 10px; font-size:12px; margin-top: 14px;" onclick="backToProfile()">Save Settings</button>
      </div>
    `;
  }

  container.innerHTML = htmlContent;
  
  document.querySelectorAll('.tab-screen').forEach(screen => {
    screen.classList.remove('active');
  });
  document.getElementById('tab-profile-subpage').classList.add('active');
}

function backToProfile() {
  switchTab('profile');
}

// ----------------------------------------------------------------------------
// 13. DEVELOPER LOGGER & UI SYNC
// ----------------------------------------------------------------------------
function logActivity(module, message) {
  console.log(`[${module}] ${message}`);
}

function updateUI() {
  const balText = `₹${appState.wallet.balance.toFixed(2)}`;
  const ptsText = `${appState.wallet.points} pts`;
  const cbText = `₹${appState.wallet.cashback.toFixed(2)}`;

  // Update navbar elements
  if (document.getElementById('nav-wallet-balance')) document.getElementById('nav-wallet-balance').innerText = balText;
  if (document.getElementById('nav-wallet-points')) document.getElementById('nav-wallet-points').innerText = ptsText;

  // Update sidebar widgets
  if (document.getElementById('side-wallet-balance')) document.getElementById('side-wallet-balance').innerText = balText;
  if (document.getElementById('side-wallet-points')) document.getElementById('side-wallet-points').innerText = ptsText;
  if (document.getElementById('side-wallet-cashback')) document.getElementById('side-wallet-cashback').innerText = cbText;

  // Update modal elements
  if (document.getElementById('wallet-balance-txt')) document.getElementById('wallet-balance-txt').innerText = balText;
  if (document.getElementById('wallet-points-txt')) document.getElementById('wallet-points-txt').innerText = ptsText;
  if (document.getElementById('wallet-cashback-txt')) document.getElementById('wallet-cashback-txt').innerText = cbText;

  // Sync Cart badge
  const cartCount = appState.cart.reduce((sum, item) => sum + item.quantity, 0);
  const cartBadge = document.getElementById('cart-badge');
  if (cartBadge) cartBadge.innerText = cartCount;

  // Update transactions list
  const txList = document.getElementById('wallet-transactions-list');
  if (txList) {
    txList.innerHTML = '';
    appState.wallet.transactions.slice(0, 5).forEach(tx => {
      txList.innerHTML += `
        <div style="display:flex; justify-content:space-between; align-items:center; border: 1px solid var(--dark-border); padding: 8px 12px; border-radius: 10px; background: rgba(0,0,0,0.1); font-size:11.5px;">
          <div>
            <div style="font-weight:bold;">${tx.title}</div>
            <div style="font-size:9px; color:var(--text-secondary); margin-top:2px;">${tx.date}</div>
          </div>
          <span style="font-weight:850; color: ${tx.isCredit ? 'var(--success)' : 'var(--error)'};">
            ${tx.isCredit ? '+' : '-'}₹${tx.amount.toFixed(0)}
          </span>
        </div>
      `;
    });
  }

  // Refresh widgets
  renderBookingsRegistry();
  updateCartDOM();
  renderNotifications();
  
  // Refresh Wallet Page
  updateWalletPageDOM();
}

// Toast helper
function showToastNotification(message) {
  const container = document.createElement('div');
  container.style.position = 'fixed';
  container.style.bottom = '30px';
  container.style.left = '50%';
  container.style.transform = 'translateX(-50%)';
  container.style.background = 'rgba(0, 0, 0, 0.85)';
  container.style.color = '#fff';
  container.style.padding = '10px 20px';
  container.style.borderRadius = '20px';
  container.style.fontSize = '12.5px';
  container.style.fontWeight = 'bold';
  container.style.zIndex = '1002';
  container.style.boxShadow = 'var(--shadow-premium)';
  container.style.animation = 'slideUp 0.3s ease';
  container.innerText = message;

  document.body.appendChild(container);
  
  setTimeout(() => {
    container.remove();
  }, 2200);
}

// Location lookup trigger
function requestLocation() {
  const txt = document.getElementById('current-location-txt');
  txt.innerText = "Locating GPS...";
  
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        txt.innerText = "Indiranagar, Bengaluru";
        logActivity(`System`, `Location updated: [Indiranagar, Bengaluru]`);
        if (leafletMap && userMarker) {
          userMarker.setLatLng(BENGALURU_COORDS); 
          recenterMap();
        }
      },
      (err) => {
        txt.innerText = "Indiranagar, Bengaluru";
      }
    );
  } else {
    txt.innerText = "Indiranagar, Bengaluru";
  }
}

// ----------------------------------------------------------------------------
// 14. WIREFRAME INTEGRATION & HELPER FUNCTIONS
// ----------------------------------------------------------------------------

function triggerNearbyFind() {
  if (leafletMap) {
    leafletMap.setView(BENGALURU_COORDS, 14, { animate: true });
    
    // Add flashing border style to map container as scan feedback
    const mapPanel = document.querySelector('.home-map-panel');
    if (mapPanel) {
      mapPanel.style.borderColor = 'var(--secondary)';
      mapPanel.style.boxShadow = '0 0 30px rgba(0, 242, 254, 0.4)';
      setTimeout(() => {
        mapPanel.style.borderColor = 'var(--card-border)';
        mapPanel.style.boxShadow = 'var(--shadow-premium)';
      }, 1500);
    }
    
    generateNearbyHotspots();
    logActivity('Map', 'Triggered NEAR BY FIND hotspot scanning pulse');
    showToastNotification('Nearby vehicles scanner active!');
  }
}

function triggerLikedRoute(fromLabel, toLabel) {
  closeModal('modal-liked');
  
  // Pre-populate ride booking inputs
  const rideFrom = document.getElementById('ride-from');
  const rideTo = document.getElementById('ride-to');
  
  if (fromLabel === 'Home' && toLabel === 'Office') {
    if (rideFrom) rideFrom.value = 'Indiranagar Home';
    if (rideTo) rideTo.value = 'Whitefield IT Park';
  } else if (fromLabel === 'Office' && toLabel === 'Airport') {
    if (rideFrom) rideFrom.value = 'Whitefield Office';
    if (rideTo) rideTo.value = 'Kempegowda Int\'l Airport';
  } else if (fromLabel === 'Home' && toLabel === 'Weekend Villa') {
    // Open maritime booking directly
    const seaFrom = document.getElementById('sea-from');
    const seaTo = document.getElementById('sea-to');
    if (seaFrom) seaFrom.value = 'Gateway of India, Mumbai';
    if (seaTo) seaTo.value = 'Mandwa Jetty, Alibaug';
    openModal('modal-sea');
    return;
  }
  
  openModal('modal-ride');
}

function loadScenicRouteNH66() {
  closeModal('modal-travel-guide');
  switchTab('home');
  document.querySelector('.web-main-content').scrollTop = 0;
  animateActiveBookingRoute('Coastal Cruise NH-66', 'sea');
  showToastNotification('Plotting Scenic NH-66 Route...');
}

function executeFindMyVehicle() {
  closeModal('modal-find-vehicle');
  switchTab('home');
  document.querySelector('.web-main-content').scrollTop = 0;
  
  if (leafletMap) {
    const vehicleCoords = [BENGALURU_COORDS[0] - 0.004, BENGALURU_COORDS[1] + 0.005];
    leafletMap.setView(vehicleCoords, 16, { animate: true });
    
    // Add locator pin
    const locatorIcon = L.divIcon({
      className: 'vehicle-locator-gps',
      html: `<div style="width: 36px; height: 36px; background: rgba(0, 82, 255, 0.2); border: 2.5px solid var(--primary); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 0 15px var(--primary); animation: pulseRed 1s infinite alternate;">
              <i class="fa-solid fa-car" style="color: #fff; font-size: 14px;"></i>
             </div>`,
      iconSize: [36, 36],
      iconAnchor: [18, 18]
    });
    
    const tempVehicleMarker = L.marker(vehicleCoords, { icon: locatorIcon }).addTo(leafletMap);
    tempVehicleMarker.bindPopup("<strong>Tata Nexon EV</strong><br>KA-03-MY-8820<br>Status: Securely Parked").openPopup();
    
    setTimeout(() => {
      leafletMap.removeLayer(tempVehicleMarker);
    }, 7000);
    
    logActivity('Telemetry', 'Located Nexon EV KA-03-MY-8820 on Home map');
    showToastNotification('Vehicle located at Indiranagar Stage 2');
  }
}

function scrollToNewsSection() {
  const el = document.getElementById('news-section-div');
  if (el) {
    el.scrollIntoView({ behavior: 'smooth' });
    showToastNotification('Navigating to Ecosystem News');
  }
}

function sendAiMessage() {
  const input = document.getElementById('ai-chat-input');
  const chatHistory = document.getElementById('ai-chat-history');
  if (!input || !chatHistory || !input.value.trim()) return;
  
  const userText = input.value.trim();
  
  // Append user message
  chatHistory.innerHTML += `
    <div class="chat-msg user">
      <p>${userText}</p>
    </div>
  `;
  
  input.value = '';
  chatHistory.scrollTop = chatHistory.scrollHeight;
  
  logActivity('AI', `User query: "${userText}"`);
  
  // Simulate assistant typing/reply
  setTimeout(() => {
    let replyText = "I have scanned the SART transit databases. Traffic flow is stable. Let me know if you need any tickets or dispatch scheduling!";
    const lower = userText.toLowerCase();
    
    if (lower.includes('battery') || lower.includes('nexon') || lower.includes('charge')) {
      replyText = "Nexon EV battery telemetry reads 84% charge. Projected range is 310 km. Cell health is optimal at 98.2%. Temperature is 31°C.";
    } else if (lower.includes('tire') || lower.includes('pressure') || lower.includes('psi')) {
      replyText = "Diagnostics alert: Front-left tire pressure reads 28 PSI (slightly low). Recommended is 33 PSI. You can purchase a portable inflator upgrade in the Store!";
    } else if (lower.includes('route') || lower.includes('commute') || lower.includes('traffic')) {
      replyText = "Ecosystem routes check: Coastal Highway NH-66 has excellent speeds. Indiranagar outer ring road reports light delays near tech depots.";
    } else if (lower.includes('parking') || lower.includes('slot')) {
      replyText = "Checking smart parking grids... Indiranagar tech zone reports 2 empty slots, including 1 EV slot with fast-charging units. You can reserve directly from Home.";
    } else if (lower.includes('hello') || lower.includes('hi')) {
      replyText = "Hello! I am your AI Copilot. I can assist with Nexon EV telemetry, real-time traffic updates, or booking options. What can I check for you?";
    }
    
    chatHistory.innerHTML += `
      <div class="chat-msg assistant">
        <p>${replyText}</p>
      </div>
    `;
    chatHistory.scrollTop = chatHistory.scrollHeight;
    logActivity('AI', `AI response: "${replyText}"`);
  }, 1000);
}

function updateWalletPageDOM() {
  const balText = `₹${appState.wallet.balance.toFixed(2)}`;
  const ptsText = `${appState.wallet.points} pts`;
  const cbText = `₹${appState.wallet.cashback.toFixed(2)}`;
  
  if (document.getElementById('wallet-pg-balance')) document.getElementById('wallet-pg-balance').innerText = balText;
  if (document.getElementById('wallet-pg-points')) document.getElementById('wallet-pg-points').innerText = ptsText;
  if (document.getElementById('wallet-pg-cashback')) document.getElementById('wallet-pg-cashback').innerText = cbText;
  
  // Transaction log sync on full page
  const pgTxList = document.getElementById('wallet-pg-transactions-list');
  if (pgTxList) {
    pgTxList.innerHTML = '';
    appState.wallet.transactions.forEach(tx => {
      pgTxList.innerHTML += `
        <div style="display:flex; justify-content:space-between; align-items:center; border:1px solid var(--dark-border); padding:10px 14px; border-radius:12px; background:rgba(0,0,0,0.15); font-size:12px;">
          <div>
            <div style="font-weight:bold; color:#fff;">${tx.title}</div>
            <div style="font-size:10px; color:var(--text-secondary); margin-top:2px;">${tx.date} • Category: ${tx.category}</div>
          </div>
          <span style="font-weight:900; font-size:13px; color: ${tx.isCredit ? 'var(--success)' : 'var(--error)'};">
            ${tx.isCredit ? '+' : '-'}₹${tx.amount.toFixed(2)}
          </span>
        </div>
      `;
    });
  }
}

function executeWalletPageDeposit() {
  const inputAmount = document.getElementById('wallet-pg-deposit-amount');
  const inputSource = document.getElementById('wallet-pg-deposit-source');
  if (!inputAmount || !inputSource) return;
  
  const amount = parseFloat(inputAmount.value);
  const source = inputSource.value;
  
  if (isNaN(amount) || amount <= 0) {
    alert("Please enter a valid deposit amount.");
    return;
  }
  
  appState.wallet.balance += amount;
  const pointsEarned = Math.floor(amount * 0.5);
  appState.wallet.points += pointsEarned;
  
  const tx = {
    id: `tx-${Date.now()}`,
    title: `Top-up via ${source}`,
    amount: amount,
    date: new Date().toLocaleString(),
    isCredit: true,
    category: 'Deposit'
  };
  appState.wallet.transactions.unshift(tx);
  
  logActivity(`Wallet`, `Loaded ₹${amount.toFixed(2)} from ${source} via Wallet Page.`);
  saveState();
  updateWalletPageDOM();
  alert(`₹${amount.toFixed(2)} Loaded Successfully!`);
}

function executeWalletPageTransfer() {
  const inputRecipient = document.getElementById('wallet-pg-transfer-recipient');
  const inputAmount = document.getElementById('wallet-pg-transfer-amount');
  if (!inputRecipient || !inputAmount) return;
  
  const recipient = inputRecipient.value.trim();
  const amount = parseFloat(inputAmount.value);
  
  if (isNaN(amount) || amount <= 0) {
    alert("Please enter a valid transfer amount.");
    return;
  }
  if (!recipient) {
    alert("Please enter recipient account details.");
    return;
  }
  if (appState.wallet.balance < amount) {
    alert("Insufficient balance for this transfer.");
    return;
  }
  
  appState.wallet.balance -= amount;
  
  const tx = {
    id: `tx-${Date.now()}`,
    title: `Transfer to ${recipient}`,
    amount: amount,
    date: new Date().toLocaleString(),
    isCredit: false,
    category: 'Transfer'
  };
  appState.wallet.transactions.unshift(tx);
  
  logActivity(`Wallet`, `Transferred ₹${amount.toFixed(2)} to ${recipient} via Wallet Page.`);
  saveState();
  updateWalletPageDOM();
  alert(`₹${amount.toFixed(2)} transferred successfully.`);
}

// ----------------------------------------------------------------------------
// 15. INITIAL BOOTSTRAP RUNNER
// ----------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', () => {
  loadState();

  // Load News list on Home Screen
  const newsRow = document.getElementById('news-cards-container');
  if (newsRow) {
    newsRow.innerHTML = '';
    AUTO_NEWS.forEach(n => {
      newsRow.innerHTML += `
        <div class="news-card" onclick="alert('${n.title}\\n\\nSource: ${n.source}\\n\\n${n.desc}')">
          <div class="news-card-header">
            <span class="news-card-tag">${n.tag}</span>
            <span class="news-card-date">${n.date}</span>
          </div>
          <div class="news-card-title">${n.title}</div>
          <div class="news-card-footer">
            <span>${n.source}</span>
            <i class="fa-solid fa-arrow-right"></i>
          </div>
        </div>
      `;
    });
  }

  // Load store products
  renderStoreProducts();

  // Sync state variables
  updateUI();

  // Init leaflet maps
  initMap();
  
  // Set default city text
  document.getElementById('current-location-txt').innerText = appState.location;
  
  // Check if an active booking was left in state, show overlay
  const activeB = appState.bookings.find(b => b.status === 'Active');
  if (activeB) {
    appState.activeBookingId = activeB.id;
    document.getElementById('map-active-booking-title').innerText = activeB.title;
    document.getElementById('map-active-booking-desc').innerText = `Active trip tracking...`;
    document.getElementById('map-active-booking-card').style.display = 'block';
    
    let mapIconClass = 'fa-car-side';
    if (activeB.type === 'sea') mapIconClass = 'fa-ship';
    else if (activeB.type === 'air') mapIconClass = 'fa-plane';
    else if (activeB.type === 'train') mapIconClass = 'fa-train';
    document.getElementById('map-active-booking-icon').className = `fa-solid ${mapIconClass}`;
    
    setTimeout(() => {
      animateActiveBookingRoute(activeB.title, activeB.type);
    }, 1000);
  }
});
