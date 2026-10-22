/**
 * MarketPulse Global Search Script
 * Queries api/search.php dynamically across companies, symbols, and country markets
 */

document.addEventListener('DOMContentLoaded', () => {
  const searchInput = document.getElementById('globalSearchInput');
  const triggerBtn = document.getElementById('triggerSearchBtn');

  // Perform initial search if value exists or default
  performSearch(searchInput ? searchInput.value.trim() : '');

  if (searchInput) {
    let debounceTimer;
    searchInput.addEventListener('input', (e) => {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(() => {
        performSearch(e.target.value.trim());
      }, 250);
    });
  }

  if (triggerBtn && searchInput) {
    triggerBtn.addEventListener('click', () => {
      performSearch(searchInput.value.trim());
    });
  }

  // Quick tags
  const tags = document.querySelectorAll('.quick-tag');
  tags.forEach(t => {
    t.addEventListener('click', (e) => {
      e.preventDefault();
      const q = t.getAttribute('data-query');
      if (searchInput) {
        searchInput.value = q;
        performSearch(q);
      }
    });
  });

  document.addEventListener('currencyChanged', () => {
    if (searchInput) performSearch(searchInput.value.trim());
  });
});

async function performSearch(query) {
  try {
    const res = await fetch(`api/search.php?q=${encodeURIComponent(query)}`);
    const json = await res.json();
    if (!json.success) return;

    renderCountryResults(json.countries);
    renderStockResults(json.stocks);
  } catch (err) {
    console.error('Search request failed:', err);
  }
}

function renderCountryResults(countries) {
  const container = document.getElementById('countryResultsContainer');
  const countBadge = document.getElementById('countryCount');
  if (!container) return;

  if (countBadge) countBadge.textContent = `${countries.length} Found`;

  if (countries.length === 0) {
    container.innerHTML = `<div class="p-3 text-muted small text-center">No matching country markets.</div>`;
    return;
  }

  container.innerHTML = countries.map(c => `
    <div class="p-3 border rounded-3 bg-light d-flex justify-content-between align-items-center" style="cursor: pointer; transition: transform 0.15s ease;" onclick="window.location.href='markets.php?country=${encodeURIComponent(c.name)}'">
      <div>
        <div class="fw-bold fs-6"><i class="bi bi-geo-alt-fill text-danger me-1"></i> ${c.name}</div>
        <div class="small text-muted">${c.exchange} • ${c.currency}</div>
      </div>
      <a href="markets.php?country=${encodeURIComponent(c.name)}" class="btn btn-sm btn-outline-primary" onclick="event.stopPropagation();">
        View Market <i class="bi bi-arrow-right ms-1"></i>
      </a>
    </div>
  `).join('');
}

function renderStockResults(stocks) {
  const tbody = document.getElementById('stockResultsBody');
  const countBadge = document.getElementById('stockCount');
  if (!tbody) return;

  if (countBadge) countBadge.textContent = `${stocks.length} Found`;

  if (stocks.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="p-4 text-muted text-center">No matching equities found. Try searching by country name or ticker symbol.</td></tr>`;
    return;
  }

  tbody.innerHTML = stocks.map(stk => {
    const isPos = stk.change >= 0;
    const badgeClass = isPos ? 'mp-badge-positive' : 'mp-badge-negative';
    const sign = isPos ? '<i class="bi bi-caret-up-fill me-1"></i>+' : '<i class="bi bi-caret-down-fill me-1"></i>';
    return `
      <tr style="cursor: pointer;" onclick="window.location.href='stock.php?symbol=${encodeURIComponent(stk.symbol)}'">
        <td>
          <a href="stock.php?symbol=${encodeURIComponent(stk.symbol)}" class="fw-bold text-dark text-decoration-none">
            ${stk.symbol}
          </a>
        </td>
        <td>
          <div class="fw-semibold">${stk.companyName}</div>
          <div class="small text-muted">${stk.sector} • ${stk.country}</div>
        </td>
        <td><span class="small text-muted">${stk.exchange}</span></td>
        <td>
          <span class="fw-bold" data-base-price="${stk.price}">
            ${MarketPulse.formatPrice(stk.price)}
          </span>
        </td>
        <td>
          <span class="${badgeClass}">
            ${sign}${stk.changePercent.toFixed(2)}%
          </span>
        </td>
        <td class="text-end" onclick="event.stopPropagation();">
          <a href="stock.php?symbol=${encodeURIComponent(stk.symbol)}" class="btn btn-sm btn-primary">
            View <i class="bi bi-arrow-right ms-1"></i>
          </a>
        </td>
      </tr>
    `;
  }).join('');
}
