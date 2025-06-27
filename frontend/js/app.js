// 전역 변수
let map;
let currentLocationMarker;
let watchId;
let isTracking = false;
let userLocations = [];
let savedMarkers = [];

// 경로 추적 관련 변수
let isRouteTracking = false;
let currentRoute = null;
let currentRoutePolyline = null;
let routePoints = [];
let lastRoutePoint = null;

// API 기본 URL - 환경에 따라 자동 설정
const API_BASE_URL = window.location.origin + '/api';

// 사용자 ID (실제 앱에서는 로그인 시스템으로 관리)
const USER_ID = 'user_' + Math.random().toString(36).substr(2, 9);

// 앱 초기화
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
});

// 앱 초기화
function initializeApp() {
    // 지도 초기화 (서울 중심으로 설정)
    map = L.map('map').setView([37.5665, 126.9780], 13);

    // OpenStreetMap 타일 레이어 추가
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // 저장된 마커들 로드
    loadMarkers();
    
    // 현재 위치 가져오기
    getCurrentLocation();
    
    showStatusMessage('앱이 초기화되었습니다!', 'success');
}

// 이벤트 리스너 설정
function setupEventListeners() {
    // 현재 위치 버튼
    document.getElementById('getCurrentLocation').addEventListener('click', getCurrentLocation);
    
    // 추적 토글 버튼
    document.getElementById('toggleTracking').addEventListener('click', toggleTracking);
    
    // 위치 저장 버튼
    document.getElementById('saveLocation').addEventListener('click', saveCurrentLocation);
    
    // 저장된 위치 버튼
    document.getElementById('loadLocations').addEventListener('click', showLocationsList);
    
    // 마커 추가 버튼
    document.getElementById('addMarker').addEventListener('click', showMarkerModal);
    
    // 경로 관련 이벤트
    document.getElementById('startRoute').addEventListener('click', showRouteStartModal);
    document.getElementById('stopRoute').addEventListener('click', stopRouteTracking);
    document.getElementById('viewRoutes').addEventListener('click', showRoutesList);
    
    // 경로 모달 이벤트
    document.getElementById('closeRouteStartModal').addEventListener('click', hideRouteStartModal);
    document.getElementById('confirmStartRoute').addEventListener('click', startRouteTracking);
    document.getElementById('cancelStartRoute').addEventListener('click', hideRouteStartModal);
    
    // 경로 목록 이벤트
    document.getElementById('closeRoutesList').addEventListener('click', hideRoutesList);
    
    // 모달 관련 이벤트
    document.getElementById('closeLocationsList').addEventListener('click', hideLocationsList);
    document.getElementById('closeMarkerModal').addEventListener('click', hideMarkerModal);
    document.getElementById('saveMarker').addEventListener('click', saveMarker);
    document.getElementById('cancelMarker').addEventListener('click', hideMarkerModal);
    
    // 색상 프리셋 이벤트
    document.querySelectorAll('.color-preset').forEach(preset => {
        preset.addEventListener('click', function() {
            const color = this.getAttribute('data-color');
            document.getElementById('routeColor').value = color;
            
            // 선택 상태 업데이트
            document.querySelectorAll('.color-preset').forEach(p => p.classList.remove('selected'));
            this.classList.add('selected');
        });
    });
    
    // 지도 클릭 이벤트
    map.on('click', onMapClick);
}

// 현재 위치 가져오기
function getCurrentLocation() {
    if (!navigator.geolocation) {
        showStatusMessage('이 브라우저는 위치 서비스를 지원하지 않습니다.', 'error');
        return;
    }

    navigator.geolocation.getCurrentPosition(
        function(position) {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            const accuracy = position.coords.accuracy;

            updateLocationDisplay(lat, lng, accuracy);
            updateMapLocation(lat, lng);
            
            showStatusMessage('현재 위치를 가져왔습니다!', 'success');
        },
        function(error) {
            handleLocationError(error);
        },
        {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 60000
        }
    );
}

// 위치 추적 토글
function toggleTracking() {
    const button = document.getElementById('toggleTracking');
    
    if (isTracking) {
        // 추적 중지
        if (watchId) {
            navigator.geolocation.clearWatch(watchId);
            watchId = null;
        }
        isTracking = false;
        button.textContent = '추적 시작';
        button.classList.remove('btn-warning');
        button.classList.add('btn-secondary');
        showStatusMessage('위치 추적을 중지했습니다.', 'info');
    } else {
        // 추적 시작
        if (!navigator.geolocation) {
            showStatusMessage('이 브라우저는 위치 서비스를 지원하지 않습니다.', 'error');
            return;
        }

        watchId = navigator.geolocation.watchPosition(
            function(position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                const accuracy = position.coords.accuracy;

                updateLocationDisplay(lat, lng, accuracy);
                updateMapLocation(lat, lng);
                
                // 위치 기록 저장 (5초마다)
                if (!userLocations.length || 
                    Date.now() - userLocations[userLocations.length - 1].timestamp > 5000) {
                    userLocations.push({
                        lat: lat,
                        lng: lng,
                        timestamp: Date.now()
                    });
                }
                
                // 경로 추적 중이면 경로 포인트 추가
                if (isRouteTracking) {
                    addRoutePoint(lat, lng, accuracy);
                }
            },
            function(error) {
                handleLocationError(error);
            },
            {
                enableHighAccuracy: true,
                timeout: 5000,
                maximumAge: 1000
            }
        );

        isTracking = true;
        button.textContent = '추적 중지';
        button.classList.remove('btn-secondary');
        button.classList.add('btn-warning');
        showStatusMessage('위치 추적을 시작했습니다.', 'success');
    }
}

// 위치 표시 업데이트
function updateLocationDisplay(lat, lng, accuracy) {
    document.getElementById('currentLat').textContent = lat.toFixed(6);
    document.getElementById('currentLng').textContent = lng.toFixed(6);
    document.getElementById('accuracy').textContent = accuracy ? accuracy.toFixed(0) + 'm' : '--';
}

// 지도 위치 업데이트
function updateMapLocation(lat, lng) {
    // 기존 현재 위치 마커 제거
    if (currentLocationMarker) {
        map.removeLayer(currentLocationMarker);
    }

    // 새 현재 위치 마커 추가
    currentLocationMarker = L.marker([lat, lng], {
        icon: L.divIcon({
            className: 'current-location-marker',
            html: '📍',
            iconSize: [30, 30],
            popupAnchor: [0, -15]
        })
    }).addTo(map);

    currentLocationMarker.bindPopup('현재 위치').openPopup();

    // 지도 중심 이동
    map.setView([lat, lng], 16);
}

// 현재 위치 저장
async function saveCurrentLocation() {
    const lat = document.getElementById('currentLat').textContent;
    const lng = document.getElementById('currentLng').textContent;

    if (lat === '--' || lng === '--') {
        showStatusMessage('먼저 현재 위치를 가져오세요.', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/save-location`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: USER_ID,
                latitude: parseFloat(lat),
                longitude: parseFloat(lng),
                address: await getAddressFromCoords(parseFloat(lat), parseFloat(lng))
            })
        });

        const data = await response.json();
        
        if (data.status === 'success') {
            showStatusMessage('위치가 저장되었습니다!', 'success');
        } else {
            showStatusMessage('위치 저장에 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error saving location:', error);
        showStatusMessage('위치 저장 중 오류가 발생했습니다.', 'error');
    }
}

// 저장된 위치 목록 표시
async function showLocationsList() {
    try {
        const response = await fetch(`${API_BASE_URL}/get-locations?user_id=${USER_ID}`);
        const data = await response.json();

        if (data.status === 'success') {
            const locationsContent = document.getElementById('locationsContent');
            locationsContent.innerHTML = '';

            if (data.locations.length === 0) {
                locationsContent.innerHTML = '<p>저장된 위치가 없습니다.</p>';
            } else {
                data.locations.forEach((location, index) => {
                    const locationItem = document.createElement('div');
                    locationItem.className = 'location-item';
                    locationItem.innerHTML = `
                        <div><strong>위치 ${index + 1}</strong></div>
                        <div>위도: ${location.latitude.toFixed(6)}</div>
                        <div>경도: ${location.longitude.toFixed(6)}</div>
                        <div>시간: ${new Date(location.timestamp).toLocaleString()}</div>
                        ${location.address ? `<div>주소: ${location.address}</div>` : ''}
                    `;
                    
                    locationItem.addEventListener('click', () => {
                        map.setView([location.latitude, location.longitude], 16);
                        hideLocationsList();
                    });
                    
                    locationsContent.appendChild(locationItem);
                });
            }

            document.getElementById('locationsList').classList.remove('hidden');
        } else {
            showStatusMessage('위치 목록을 불러오는데 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error loading locations:', error);
        showStatusMessage('위치 목록 로딩 중 오류가 발생했습니다.', 'error');
    }
}

// 위치 목록 숨기기
function hideLocationsList() {
    document.getElementById('locationsList').classList.add('hidden');
}

// 마커 추가 모달 표시
function showMarkerModal() {
    const lat = document.getElementById('currentLat').textContent;
    const lng = document.getElementById('currentLng').textContent;

    if (lat === '--' || lng === '--') {
        showStatusMessage('먼저 현재 위치를 가져오거나 지도를 클릭하세요.', 'error');
        return;
    }

    document.getElementById('markerModal').classList.remove('hidden');
}

// 마커 추가 모달 숨기기
function hideMarkerModal() {
    document.getElementById('markerModal').classList.add('hidden');
    // 폼 초기화
    document.getElementById('markerName').value = '';
    document.getElementById('markerDescription').value = '';
    document.getElementById('markerCategory').value = 'general';
}

// 마커 저장
async function saveMarker() {
    const name = document.getElementById('markerName').value.trim();
    const description = document.getElementById('markerDescription').value.trim();
    const category = document.getElementById('markerCategory').value;
    const lat = parseFloat(document.getElementById('currentLat').textContent);
    const lng = parseFloat(document.getElementById('currentLng').textContent);

    if (!name) {
        showStatusMessage('장소명을 입력하세요.', 'error');
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/add-marker`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                name: name,
                latitude: lat,
                longitude: lng,
                description: description,
                category: category
            })
        });

        const data = await response.json();
        
        if (data.status === 'success') {
            showStatusMessage('마커가 추가되었습니다!', 'success');
            hideMarkerModal();
            loadMarkers(); // 마커 다시 로드
        } else {
            showStatusMessage('마커 추가에 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error saving marker:', error);
        showStatusMessage('마커 저장 중 오류가 발생했습니다.', 'error');
    }
}

// 저장된 마커들 로드
async function loadMarkers() {
    try {
        const response = await fetch(`${API_BASE_URL}/get-markers`);
        const data = await response.json();

        if (data.status === 'success') {
            // 기존 마커들 제거 (현재 위치 마커 제외)
            savedMarkers.forEach(marker => {
                map.removeLayer(marker);
            });
            savedMarkers = [];

            // 새 마커들 추가
            data.markers.forEach(markerData => {
                const icon = getMarkerIcon(markerData.category);
                const marker = L.marker([markerData.latitude, markerData.longitude], {
                    icon: icon
                }).addTo(map);

                marker.bindPopup(`
                    <div>
                        <h4>${markerData.name}</h4>
                        <p><strong>카테고리:</strong> ${getCategoryName(markerData.category)}</p>
                        ${markerData.description ? `<p><strong>설명:</strong> ${markerData.description}</p>` : ''}
                        <p><small>추가된 시간: ${new Date(markerData.created_at).toLocaleString()}</small></p>
                    </div>
                `);

                savedMarkers.push(marker);
            });
        }
    } catch (error) {
        console.error('Error loading markers:', error);
    }
}

// 지도 클릭 이벤트 처리
function onMapClick(e) {
    const lat = e.latlng.lat;
    const lng = e.latlng.lng;
    
    updateLocationDisplay(lat, lng, null);
    
    // 임시 마커 표시
    if (currentLocationMarker) {
        map.removeLayer(currentLocationMarker);
    }
    
    currentLocationMarker = L.marker([lat, lng], {
        icon: L.divIcon({
            className: 'current-location-marker',
            html: '📍',
            iconSize: [30, 30],
            popupAnchor: [0, -15]
        })
    }).addTo(map);

    currentLocationMarker.bindPopup('선택된 위치').openPopup();
}

// 카테고리별 마커 아이콘 가져오기
function getMarkerIcon(category) {
    const icons = {
        general: '📍',
        restaurant: '🍽️',
        cafe: '☕',
        shopping: '🛍️',
        hospital: '🏥',
        school: '🏫',
        work: '💼',
        home: '🏠'
    };

    return L.divIcon({
        className: 'custom-marker',
        html: icons[category] || icons.general,
        iconSize: [30, 30],
        popupAnchor: [0, -15]
    });
}

// 카테고리 이름 가져오기
function getCategoryName(category) {
    const names = {
        general: '일반',
        restaurant: '음식점',
        cafe: '카페',
        shopping: '쇼핑',
        hospital: '병원',
        school: '학교',
        work: '직장',
        home: '집'
    };
    return names[category] || names.general;
}

// 좌표에서 주소 가져오기 (Nominatim API 사용)
async function getAddressFromCoords(lat, lng) {
    try {
        const response = await fetch(
            `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`
        );
        const data = await response.json();
        return data.display_name || '';
    } catch (error) {
        console.error('Error getting address:', error);
        return '';
    }
}

// 위치 오류 처리
function handleLocationError(error) {
    let message = '';
    switch(error.code) {
        case error.PERMISSION_DENIED:
            message = '위치 접근이 거부되었습니다. 브라우저 설정에서 위치 권한을 허용해주세요.';
            break;
        case error.POSITION_UNAVAILABLE:
            message = '위치 정보를 사용할 수 없습니다.';
            break;
        case error.TIMEOUT:
            message = '위치 요청 시간이 초과되었습니다.';
            break;
        default:
            message = '알 수 없는 오류가 발생했습니다.';
            break;
    }
    showStatusMessage(message, 'error');
}

// 상태 메시지 표시
function showStatusMessage(message, type = 'success') {
    const statusElement = document.getElementById('statusMessage');
    statusElement.textContent = message;
    statusElement.className = `status-message ${type}`;
    statusElement.classList.remove('hidden');
    statusElement.classList.add('show');
    
    // 3초 후 자동으로 숨기기
    setTimeout(() => {
        statusElement.classList.remove('show');
        setTimeout(() => {
            statusElement.classList.add('hidden');
        }, 300);
    }, 3000);
}

// 유틸리티 함수들
function formatCoordinate(coord) {
    return coord.toFixed(6);
}

function formatTimestamp(timestamp) {
    return new Date(timestamp).toLocaleString('ko-KR');
}

// 앱 종료 시 추적 정리
window.addEventListener('beforeunload', function() {
    if (watchId) {
        navigator.geolocation.clearWatch(watchId);
    }
});

// ===========================================
// 경로 추적 관련 함수들
// ===========================================

// 경로 시작 모달 표시
function showRouteStartModal() {
    // 기본 경로 이름 설정
    const now = new Date();
    const defaultName = `여행 ${now.getFullYear()}-${(now.getMonth()+1).toString().padStart(2,'0')}-${now.getDate().toString().padStart(2,'0')} ${now.getHours().toString().padStart(2,'0')}:${now.getMinutes().toString().padStart(2,'0')}`;
    document.getElementById('routeName').value = defaultName;
    
    document.getElementById('routeStartModal').classList.remove('hidden');
}

// 경로 시작 모달 숨기기
function hideRouteStartModal() {
    document.getElementById('routeStartModal').classList.add('hidden');
    // 폼 초기화
    document.getElementById('routeName').value = '';
    document.getElementById('routeDescription').value = '';
    document.getElementById('routeColor').value = '#FF0000';
    document.querySelectorAll('.color-preset').forEach(p => p.classList.remove('selected'));
}

// 경로 추적 시작
async function startRouteTracking() {
    const routeName = document.getElementById('routeName').value.trim();
    const routeDescription = document.getElementById('routeDescription').value.trim();
    const routeColor = document.getElementById('routeColor').value;
    
    if (!routeName) {
        showStatusMessage('경로 이름을 입력하세요.', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/start-route`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: USER_ID,
                route_name: routeName,
                description: routeDescription,
                color: routeColor
            })
        });
        
        const data = await response.json();
        
        if (data.status === 'success') {
            isRouteTracking = true;
            currentRoute = {
                id: data.route_id,
                name: routeName,
                description: routeDescription,
                color: routeColor
            };
            routePoints = [];
            
            // UI 업데이트
            document.getElementById('startRoute').classList.add('hidden');
            document.getElementById('stopRoute').classList.remove('hidden');
            document.getElementById('trackingStatus').classList.remove('hidden');
            
            // 경로 라인 초기화
            if (currentRoutePolyline) {
                map.removeLayer(currentRoutePolyline);
            }
            currentRoutePolyline = L.polyline([], {
                color: routeColor,
                weight: 4,
                opacity: 0.8
            }).addTo(map);
            
            hideRouteStartModal();
            showStatusMessage(`${routeName} 경로 추적을 시작했습니다!`, 'success');
            
            // 위치 추적도 시작
            if (!isTracking) {
                toggleTracking();
            }
        } else {
            showStatusMessage('경로 시작에 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error starting route:', error);
        showStatusMessage('경로 시작 중 오류가 발생했습니다.', 'error');
    }
}

// 경로 추적 중지
async function stopRouteTracking() {
    if (!isRouteTracking) return;
    
    try {
        const response = await fetch(`${API_BASE_URL}/stop-route`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: USER_ID
            })
        });
        
        const data = await response.json();
        
        if (data.status === 'success') {
            isRouteTracking = false;
            currentRoute = null;
            
            // UI 업데이트
            document.getElementById('startRoute').classList.remove('hidden');
            document.getElementById('stopRoute').classList.add('hidden');
            document.getElementById('trackingStatus').classList.add('hidden');
            
            showStatusMessage('경로 추적이 완료되었습니다!', 'success');
        } else {
            showStatusMessage('경로 중지에 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error stopping route:', error);
        showStatusMessage('경로 중지 중 오류가 발생했습니다.', 'error');
    }
}

// 경로에 포인트 추가
async function addRoutePoint(lat, lng, accuracy) {
    if (!isRouteTracking || !currentRoute) return;
    
    // 너무 가까운 포인트는 제외 (최소 10m 거리)
    if (lastRoutePoint) {
        const distance = calculateDistance(
            lastRoutePoint.lat, lastRoutePoint.lng,
            lat, lng
        );
        if (distance < 10) return; // 10m 미만은 무시
    }
    
    try {
        const response = await fetch(`${API_BASE_URL}/add-route-point`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: USER_ID,
                latitude: lat,
                longitude: lng,
                accuracy: accuracy
            })
        });
        
        const data = await response.json();
        
        if (data.status === 'success') {
            // 경로 포인트 배열에 추가
            const newPoint = [lat, lng];
            routePoints.push(newPoint);
            lastRoutePoint = { lat, lng };
            
            // 폴리라인 업데이트
            if (currentRoutePolyline) {
                currentRoutePolyline.setLatLngs(routePoints);
            }
        }
    } catch (error) {
        console.error('Error adding route point:', error);
    }
}

// 여행 경로 목록 표시
async function showRoutesList() {
    try {
        const response = await fetch(`${API_BASE_URL}/get-routes?user_id=${USER_ID}`);
        const data = await response.json();
        
        if (data.status === 'success') {
            const routesContent = document.getElementById('routesContent');
            routesContent.innerHTML = '';
            
            if (data.routes.length === 0) {
                routesContent.innerHTML = '<p>저장된 여행 경로가 없습니다.</p>';
            } else {
                data.routes.forEach(route => {
                    const routeItem = document.createElement('div');
                    routeItem.className = `route-item ${route.is_active ? 'active' : ''}`;
                    routeItem.innerHTML = `
                        <div class="route-info">
                            <div style="display: flex; align-items: center;">
                                <div class="route-color-indicator" style="background: ${route.color}"></div>
                                <span class="route-name">${route.route_name}</span>
                            </div>
                            <span class="route-status ${route.is_active ? 'active' : 'completed'}">
                                ${route.is_active ? '추적 중' : '완료'}
                            </span>
                        </div>
                        ${route.description ? `<div class="route-description">${route.description}</div>` : ''}
                        <div class="route-meta">
                            생성일: ${new Date(route.created_at).toLocaleString()}
                        </div>
                    `;
                    
                    routeItem.addEventListener('click', () => {
                        loadAndDisplayRoute(route.id);
                        hideRoutesList();
                    });
                    
                    routesContent.appendChild(routeItem);
                });
            }
            
            document.getElementById('routesList').classList.remove('hidden');
        } else {
            showStatusMessage('경로 목록을 불러오는데 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error loading routes:', error);
        showStatusMessage('경로 목록 로딩 중 오류가 발생했습니다.', 'error');
    }
}

// 경로 목록 숨기기
function hideRoutesList() {
    document.getElementById('routesList').classList.add('hidden');
}

// 특정 경로 로드 및 표시
async function loadAndDisplayRoute(routeId) {
    try {
        const response = await fetch(`${API_BASE_URL}/get-route-points?route_id=${routeId}`);
        const data = await response.json();
        
        if (data.status === 'success') {
            const points = data.points.map(point => [point.latitude, point.longitude]);
            
            if (points.length > 0) {
                // 기존 경로 라인 제거 (현재 추적 중인 경로 제외)
                map.eachLayer(layer => {
                    if (layer instanceof L.Polyline && layer !== currentRoutePolyline) {
                        map.removeLayer(layer);
                    }
                });
                
                // 새 경로 라인 추가
                const routeLine = L.polyline(points, {
                    color: data.route_info.color,
                    weight: 4,
                    opacity: 0.8
                }).addTo(map);
                
                // 경로 전체가 보이도록 지도 화면 조정
                map.fitBounds(routeLine.getBounds(), { padding: [20, 20] });
                
                // 경로 정보 표시
                const startPoint = points[0];
                const endPoint = points[points.length - 1];
                
                L.marker(startPoint, {
                    icon: L.divIcon({
                        className: 'route-marker start-marker',
                        html: '🟢',
                        iconSize: [25, 25]
                    })
                }).addTo(map).bindPopup(`<b>${data.route_info.name}</b><br>시작점`);
                
                if (points.length > 1) {
                    L.marker(endPoint, {
                        icon: L.divIcon({
                            className: 'route-marker end-marker',
                            html: '🔴',
                            iconSize: [25, 25]
                        })
                    }).addTo(map).bindPopup(`<b>${data.route_info.name}</b><br>종료점`);
                }
                
                showStatusMessage(`${data.route_info.name} 경로가 표시되었습니다.`, 'success');
            } else {
                showStatusMessage('해당 경로에 포인트가 없습니다.', 'info');
            }
        } else {
            showStatusMessage('경로를 불러오는데 실패했습니다: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Error loading route:', error);
        showStatusMessage('경로 로딩 중 오류가 발생했습니다.', 'error');
    }
}

// 두 지점 간 거리 계산 (미터 단위)
function calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371000; // 지구 반지름 (미터)
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng/2) * Math.sin(dLng/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}
