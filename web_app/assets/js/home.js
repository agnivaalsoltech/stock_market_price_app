/**
 * MarketPulse Home Page Script
 * Manages Quick Country Switching, Dynamic Indices & Trending Stocks, and Watchlist Stars
 */

document.addEventListener('DOMContentLoaded', () => {
  const countrySelect = document.getElementById('countrySelectQuick');

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

  // Watchlist buttons click handler
  document.addEventListener('click', (e) => {
    const starBtn = e.target.closest('.mp-star-btn');
    if (starBtn) {
      e.stopPropagation();
      const sym = starBtn.getAttribute('data-symbol');
      MarketPulse.toggleWatchlist(sym);
      syncStarButtons();
    }
  });

  document.addEventListener('watchlistChanged', () => {
    syncStarButtons();
  });

  syncStarButtons();

  if (countrySelect) {
    // If MarketPulse already has a country selected, sync home dropdown on load
    if (countrySelect.value !== MarketPulse.currentCountry && MarketPulse.countryCurrencies[MarketPulse.currentCountry]) {
      countrySelect.value = MarketPulse.currentCountry;
    }

    // When navbar country changes, sync home page view
    document.addEventListener('countryChanged', (e) => {
      if (countrySelect && countrySelect.value !== e.detail.country) {
        countrySelect.value = e.detail.country;
        countrySelect.dispatchEvent(new Event('change'));
      }
    });

    countrySelect.addEventListener('change', async (e) => {
      const selected = e.target.value;
      MarketPulse.setCountry(selected, true);

      // Fetch country search data to dynamically refresh indices and stocks
      try {
        const res = await fetch(`api/search.php?q=${encodeURIComponent(selected)}`);
        const json = await res.json();
        if (json.success && json.countries.length > 0) {
          const c = json.countries[0];
          const countryTitleEl = document.getElementById('countryTitle');
          const countryFlagEl = document.getElementById('countryFlag');
          const exchangeTitleEl = document.getElementById('exchangeTitle');

          if (countryTitleEl) countryTitleEl.textContent = c.name;
          if (countryFlagEl) countryFlagEl.textContent = c.flag;
          if (exchangeTitleEl) exchangeTitleEl.textContent = c.exchange;

          // Re-render indices cards with full interactive clicks
          const container = document.getElementById('indicesContainer');
          if (container && c.indices) {
            container.innerHTML = c.indices.map(idx => {
              const isPos = idx.change >= 0;
              const badgeClass = isPos ? 'mp-badge-positive' : 'mp-badge-negative';
              const arrow = isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>';
              const changeColor = isPos ? 'text-success' : 'text-danger';
              const sign = isPos ? '+' : '';
              return `
                <div class="col-12 col-sm-6 col-xl-4">
                  <div class="mp-card h-100" style="cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease;" onclick="window.location.href='markets.php?country=${encodeURIComponent(c.name)}'" title="View ${idx.name} in Markets">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                      <div>
                        <span class="text-muted small fw-bold text-uppercase">${idx.symbol}</span>
                        <h3 class="h5 fw-bold mb-0">${idx.name}</h3>
                      </div>
                      <span class="${badgeClass}">${arrow}${idx.changePercent.toFixed(2)}%</span>
                    </div>
                    <div class="d-flex align-items-baseline gap-2 mt-2">
                      <span class="fs-3 fw-bold" data-base-price="${idx.price}">
                        ${MarketPulse.formatPrice(idx.price)}
                      </span>
                      <span class="small ${changeColor} fw-semibold">${sign}${idx.change.toFixed(2)}</span>
                    </div>
                    <div class="mt-3 pt-2 border-top border-light d-flex justify-content-between small text-muted">
                      <span>Updated live</span>
                      <a href="markets.php?country=${encodeURIComponent(c.name)}" class="fw-semibold text-primary text-decoration-none">View Index <i class="bi bi-arrow-right ms-1"></i></a>
                    </div>
                  </div>
                </div>
              `;
            }).join('');
          }

          // Re-render trending stocks for selected country
          const stocksTbody = document.getElementById('trendingStocksBody');
          if (stocksTbody && json.stocks) {
            const countryStocks = json.stocks.filter(s => s.country.toLowerCase() === selected.toLowerCase());
            const displayStocks = countryStocks.length > 0 ? countryStocks.slice(0, 5) : json.stocks.slice(0, 5);
            
            stocksTbody.innerHTML = displayStocks.map(stk => {
              const isPos = stk.change >= 0;
              const badgeClass = isPos ? 'mp-badge-positive' : 'mp-badge-negative';
              const arrow = isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>';
              const sign = isPos ? '+' : '';
              const isWatched = MarketPulse.isWatched(stk.symbol);
              return `
                <tr onclick="window.location.href='stock.php?symbol=${encodeURIComponent(stk.symbol)}'" style="cursor: pointer;">
                  <td onclick="event.stopPropagation();">
                    <button class="mp-star-btn ${isWatched ? 'starred' : ''}" data-symbol="${stk.symbol}" title="Toggle Watchlist">
                      ${isWatched ? '<i class="bi bi-star-fill text-warning"></i>' : '<i class="bi bi-star"></i>'}
                    </button>
                  </td>
                  <td>
                    <a href="stock.php?symbol=${encodeURIComponent(stk.symbol)}" class="fw-bold text-dark text-decoration-none">
                      ${stk.symbol}
                    </a>
                  </td>
                  <td>
                    <div class="fw-semibold">${stk.companyName}</div>
                    <div class="small text-muted">${stk.sector}</div>
                  </td>
                  <td>
                    <span class="fw-bold" data-base-price="${stk.price}">
                      ${MarketPulse.formatPrice(stk.price)}
                    </span>
                  </td>
                  <td>
                    <span class="${badgeClass}">
                      ${arrow}${stk.changePercent.toFixed(2)}%
                    </span>
                  </td>
                  <td class="text-end" onclick="event.stopPropagation();">
                    <a href="stock.php?symbol=${encodeURIComponent(stk.symbol)}" class="btn btn-sm btn-outline-primary">
                      Details <i class="bi bi-arrow-right ms-1"></i>
                    </a>
                  </td>
                </tr>
              `;
            }).join('');
          }

          MarketPulse.updatePricesOnPage();
          syncStarButtons();
        }
      } catch (err) {
        console.error('Failed to switch country data:', err);
      }
    });
  }
});
