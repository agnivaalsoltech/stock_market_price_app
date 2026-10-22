/**
 * MarketPulse Markets Snapshot Script
 * Implements real-time table filtering, Gainers/Losers, Watchlist toggles, and Index telemetry modals
 */

document.addEventListener('DOMContentLoaded', () => {
  const filterInput = document.getElementById('marketFilterInput');
  const table = document.getElementById('marketsTable');
  const allBtn = document.getElementById('filterAllBtn');
  const watchlistBtn = document.getElementById('filterWatchlistBtn');
  const gainersBtn = document.getElementById('filterGainersBtn');
  const losersBtn = document.getElementById('filterLosersBtn');
  let currentTab = 'all'; // 'all', 'watchlist', 'gainers', 'losers'

  function syncStarButtons() {
    const starBtns = document.querySelectorAll('.mp-star-btn');
    starBtns.forEach(btn => {
      const sym = btn.getAttribute('data-symbol');
      if (MarketPulse.isWatched(sym)) {
        btn.classList.add('starred');
        btn.innerHTML = '<i class="bi bi-star-fill text-warning"></i>';
      } else {
        btn.classList.remove('starred');
        btn.innerHTML = '<i class="bi bi-star"></i>';
      }
    });
  }

  function applyFilters() {
    if (!table) return;
    const q = filterInput ? filterInput.value.toLowerCase().trim() : '';
    const rows = table.querySelectorAll('tbody tr');
    let visible = 0;

    rows.forEach(row => {
      const sym = row.getAttribute('data-symbol') || '';
      const text = row.textContent.toLowerCase();
      const matchesSearch = text.includes(q);

      let matchesTab = true;
      if (currentTab === 'watchlist') {
        matchesTab = MarketPulse.isWatched(sym);
      } else if (currentTab === 'gainers') {
        matchesTab = row.classList.contains('trend-positive');
      } else if (currentTab === 'losers') {
        matchesTab = row.classList.contains('trend-negative');
      }

      if (matchesSearch && matchesTab) {
        row.style.display = '';
        visible++;
      } else {
        row.style.display = 'none';
      }
    });

    const badge = document.getElementById('stockCountBadge');
    if (badge) {
      badge.textContent = `${visible} Shown`;
    }
  }

  function setActiveTab(tab, activeBtn) {
    currentTab = tab;
    [allBtn, watchlistBtn, gainersBtn, losersBtn].forEach(b => {
      if (b) b.classList.remove('active');
    });
    if (activeBtn) activeBtn.classList.add('active');
    applyFilters();
  }

  syncStarButtons();

  // Watchlist buttons click
  document.addEventListener('click', (e) => {
    const starBtn = e.target.closest('.mp-star-btn');
    if (starBtn) {
      e.stopPropagation();
      const sym = starBtn.getAttribute('data-symbol');
      MarketPulse.toggleWatchlist(sym);
      syncStarButtons();
      applyFilters();
    }
  });

  document.addEventListener('watchlistChanged', () => {
    syncStarButtons();
    applyFilters();
  });

  if (filterInput) {
    filterInput.addEventListener('input', applyFilters);
  }

  if (allBtn) {
    allBtn.addEventListener('click', () => setActiveTab('all', allBtn));
  }
  if (watchlistBtn) {
    watchlistBtn.addEventListener('click', () => setActiveTab('watchlist', watchlistBtn));
  }
  if (gainersBtn) {
    gainersBtn.addEventListener('click', () => setActiveTab('gainers', gainersBtn));
  }
  if (losersBtn) {
    losersBtn.addEventListener('click', () => setActiveTab('losers', losersBtn));
  }

  // Index Cards click to open Index Telemetry Modal
  const indexCards = document.querySelectorAll('.mp-index-card');
  const indexModalEl = document.getElementById('indexDetailModal');
  let activeIndexModal = null;
  if (indexModalEl) {
    activeIndexModal = new bootstrap.Modal(indexModalEl);
  }

  indexCards.forEach(card => {
    card.addEventListener('click', () => {
      const name = card.getAttribute('data-name');
      const symbol = card.getAttribute('data-symbol');
      const price = parseFloat(card.getAttribute('data-price') || '0');
      const change = parseFloat(card.getAttribute('data-change') || '0');
      const changePct = parseFloat(card.getAttribute('data-change-pct') || '0');
      const isPos = change >= 0;

      const titleEl = document.getElementById('indexModalTitle');
      const subEl = document.getElementById('indexModalSubtitle');
      const priceEl = document.getElementById('indexModalPrice');
      const changeEl = document.getElementById('indexModalChange');
      const filterBtn = document.getElementById('indexFilterStocksBtn');

      if (titleEl) titleEl.textContent = `${name} (${symbol})`;
      if (subEl) subEl.textContent = `Real-time benchmark index telemetry`;
      if (priceEl) priceEl.textContent = MarketPulse.formatPrice(price);
      if (changeEl) {
        changeEl.textContent = `${isPos ? '+' : ''}${change.toFixed(2)} (${isPos ? '+' : ''}${changePct.toFixed(2)}%)`;
        changeEl.className = `fw-bold ${isPos ? 'text-success' : 'text-danger'}`;
      }

      if (filterBtn) {
        filterBtn.onclick = () => {
          if (activeIndexModal) activeIndexModal.hide();
          if (filterInput) {
            filterInput.value = '';
            setActiveTab('all', allBtn);
            filterInput.focus();
          }
        };
      }

      if (activeIndexModal) {
        activeIndexModal.show();
      }
    });
  });
});
