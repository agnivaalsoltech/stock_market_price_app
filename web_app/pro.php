<?php
$pageTitle = 'Pro Membership - MarketPulse';
$currentPage = 'pro';
require_once __DIR__ . '/includes/header.php';
?>

<div class="container py-5">
    <!-- Hero Header -->
    <div class="text-center mb-5">
        <span class="badge bg-primary-subtle text-primary mb-2 px-3 py-2 fw-semibold">MarketPulse Pro</span>
        <h1 class="display-5 fw-bold mb-3">Elevate Your Market Intelligence</h1>
        <p class="lead text-muted mx-auto" style="max-width: 650px;">
            Unlock advanced technical indicators, unlimited portfolio tracking, multi-year historical archives, and priority exchange telemetry.
        </p>
    </div>

    <!-- Active Pro Notification Banner if user upgraded -->
    <div id="proActiveBanner" class="alert alert-success d-none text-center shadow-sm mb-4" role="alert">
        <h4 class="alert-heading fw-bold mb-1"><i class="bi bi-patch-check-fill text-success me-2"></i> Pro Status Activated!</h4>
        <p class="mb-0 small">Your account is currently enrolled in MarketPulse Pro Monthly. All premium analytical tools are active.</p>
    </div>

    <!-- Pricing Cards Row -->
    <div class="row g-4 justify-content-center mb-5">
        <!-- Free Plan -->
        <div class="col-12 col-md-6 col-lg-5">
            <div class="mp-card h-100 p-4 border">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="h5 fw-bold mb-0">Free Standard</h3>
                    <span class="badge bg-light text-dark border">Current Plan</span>
                </div>
                <div class="mb-4">
                    <span class="display-6 fw-bold" data-base-price="0">€0</span>
                    <span class="text-muted">/ forever</span>
                </div>
                <p class="text-muted small mb-4">Essential market surveillance tools for everyday individual investors and market watchers.</p>
                <ul class="list-unstyled small mb-4">
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> Real-time standard quotes</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> 1-Day to 1-Year basic charts</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> Up to 5 portfolio positions</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> Standard financial news feed</li>
                    <li class="mb-2 text-muted text-decoration-line-through"><i class="bi bi-x-circle text-muted me-2"></i> Multi-year historical tables</li>
                    <li class="mb-2 text-muted text-decoration-line-through"><i class="bi bi-x-circle text-muted me-2"></i> Unlimited portfolio tracking</li>
                    <li class="mb-2 text-muted text-decoration-line-through"><i class="bi bi-x-circle text-muted me-2"></i> Priority API latency</li>
                </ul>
                <button class="btn btn-outline-secondary w-100 py-2" disabled>Default Active</button>
            </div>
        </div>

        <!-- Pro Plan -->
        <div class="col-12 col-md-6 col-lg-5">
            <div class="mp-card h-100 p-4 border-primary position-relative shadow" style="border-width: 2px;">
                <div class="position-absolute top-0 end-0 translate-middle-y me-3">
                    <span class="badge bg-primary px-3 py-2 text-uppercase fw-bold"><i class="bi bi-star-fill text-warning me-1"></i> Most Popular</span>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="h5 fw-bold text-primary mb-0">MarketPulse Pro</h3>
                    <span class="badge bg-primary-subtle text-primary">Full Power</span>
                </div>
                <div class="mb-4">
                    <span class="display-6 fw-bold text-dark" data-base-price="9.99">€9.99</span>
                    <span class="text-muted">/ month</span>
                </div>
                <p class="text-muted small mb-4">Advanced toolkit designed for active traders demanding deep historical metrics and multi-market scope.</p>
                <ul class="list-unstyled small mb-4">
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Ultra-low latency</strong> market quotes</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Advanced Chart.js</strong> multi-range visualizers</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Unlimited</strong> portfolio positions & allocation</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Deep historical</strong> tables and data exports</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Unlimited</strong> custom watchlists</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> <strong>Priority</strong> live news telemetry</li>
                    <li class="mb-2"><i class="bi bi-check-circle-fill text-success me-2"></i> Multi-currency real-time recalculations</li>
                </ul>
                <button id="upgradeProBtn" class="btn mp-btn-primary w-100 py-2" data-bs-toggle="modal" data-bs-target="#proCheckoutModal">
                    <i class="bi bi-lightning-charge-fill me-1"></i> Upgrade to Pro (€9.99 / mo)
                </button>
            </div>
        </div>
    </div>

    <!-- Feature Comparison Matrix -->
    <div class="mp-card p-4">
        <h3 class="h5 fw-bold mb-3">Comprehensive Feature Comparison</h3>
        <div class="table-responsive">
            <table class="mp-table align-middle">
                <thead>
                    <tr>
                        <th style="width: 50%;">Feature</th>
                        <th class="text-center" style="width: 25%;">Standard (Free)</th>
                        <th class="text-center text-primary" style="width: 25%;">MarketPulse Pro</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Market Data & Quotations</td>
                        <td class="text-center">Standard 15-min</td>
                        <td class="text-center fw-bold text-success">Real-time Live</td>
                    </tr>
                    <tr>
                        <td>Chart Ranges (1D, 1M, 3M, 1Y)</td>
                        <td class="text-center">Included</td>
                        <td class="text-center fw-bold text-success">Included + High-Res</td>
                    </tr>
                    <tr>
                        <td>Portfolio Holdings Limit</td>
                        <td class="text-center">Up to 5 stocks</td>
                        <td class="text-center fw-bold text-success">Unlimited Positions</td>
                    </tr>
                    <tr>
                        <td>Asset Allocation Analytics</td>
                        <td class="text-center">Basic</td>
                        <td class="text-center fw-bold text-success">Advanced Doughnut Breakdown</td>
                    </tr>
                    <tr>
                        <td>Historical Data Tables</td>
                        <td class="text-center">5 Days</td>
                        <td class="text-center fw-bold text-success">Multi-Year Archive</td>
                    </tr>
                    <tr>
                        <td>Country Market Switching</td>
                        <td class="text-center">Included</td>
                        <td class="text-center fw-bold text-success">Included</td>
                    </tr>
                    <tr>
                        <td>Currency Conversion (EUR, USD, GBP, INR)</td>
                        <td class="text-center">Included</td>
                        <td class="text-center fw-bold text-success">Included</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal: Simulated Checkout -->
<div class="modal fade" id="proCheckoutModal" tabindex="-1" aria-labelledby="proCheckoutModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="proCheckoutModalLabel">Confirm Upgrade to Pro</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="p-3 bg-light rounded-3 mb-3">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Subscription Plan:</span>
                        <strong class="text-primary">MarketPulse Pro (Monthly)</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Billing Cycle:</span>
                        <span>Monthly recurrent</span>
                    </div>
                    <div class="d-flex justify-content-between mb-0 pt-2 border-top">
                        <span class="fw-bold">Total Due Now:</span>
                        <strong class="fs-5 text-dark" data-base-price="9.99">€9.99</strong>
                    </div>
                </div>

                <div class="alert alert-info small mb-3">
                    <i class="bi bi-info-circle-fill text-primary me-2"></i> <strong>Academic Presentation Mode:</strong> Real payment integration is optional in the exam brief. This simulated checkout will instantly unlock Pro features for your session.
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-semibold">Cardholder Name</label>
                    <input type="text" class="form-control" value="Alex Morgan" id="checkoutName">
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-semibold">Card Number</label>
                    <input type="text" class="form-control" value="•••• •••• •••• 4242" id="checkoutCard">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn mp-btn-primary btn-sm px-4" onclick="confirmProUpgrade()"><i class="bi bi-patch-check-fill me-1"></i> Confirm Purchase</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Manage Pro Subscription -->
<div class="modal fade" id="manageProModal" tabindex="-1" aria-labelledby="manageProModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold" id="manageProModalLabel"><i class="bi bi-patch-check-fill text-warning me-2"></i> MarketPulse Pro Active</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="p-3 bg-light rounded-3 mb-3">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted small">Subscription Tier</span>
                        <strong class="text-primary">Quantitative Pro (Monthly)</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted small">Renewal Date</span>
                        <span>Auto-renews next month</span>
                    </div>
                    <div class="d-flex justify-content-between mb-0 pt-2 border-top">
                        <span class="fw-bold small">Current Status</span>
                        <span class="badge bg-success"><i class="bi bi-record-fill me-1"></i>Active & Enrolled</span>
                    </div>
                </div>
                <div class="alert alert-light border small text-muted mb-3">
                    Your account has unrestricted access to sub-second streaming quotes, unlimited portfolio models, and institutional analytics.
                </div>
                <div class="d-grid gap-2">
                    <button class="btn btn-outline-secondary btn-sm" onclick="alert('Receipt downloaded: MarketPulse-Pro-Invoice-#4092.pdf')">
                        <i class="bi bi-file-earmark-arrow-down-fill me-1"></i> Download Latest Invoice
                    </button>
                    <button class="btn btn-outline-danger btn-sm" onclick="cancelProSubscription()">
                        <i class="bi bi-x-circle-fill me-1"></i> Cancel Subscription (Downgrade to Standard)
                    </button>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
  checkProStatus();
});

function checkProStatus() {
  const isPro = localStorage.getItem('mp_is_pro') === 'true';
  const banner = document.getElementById('proActiveBanner');
  const btn = document.getElementById('upgradeProBtn');

  if (isPro) {
    if (banner) banner.classList.remove('d-none');
    if (btn) {
      btn.innerHTML = '<i class="bi bi-gear-fill me-1"></i> Manage Pro Subscription (Active)';
      btn.className = 'btn btn-success w-100 py-2';
      btn.setAttribute('data-bs-toggle', 'modal');
      btn.setAttribute('data-bs-target', '#manageProModal');
      btn.disabled = false;
    }
  } else {
    if (banner) banner.classList.add('d-none');
    if (btn) {
      btn.innerHTML = '<i class="bi bi-lightning-charge-fill me-1"></i> Upgrade to Pro (€9.99 / mo)';
      btn.className = 'btn mp-btn-primary w-100 py-2';
      btn.setAttribute('data-bs-toggle', 'modal');
      btn.setAttribute('data-bs-target', '#proCheckoutModal');
      btn.disabled = false;
    }
  }
}

function confirmProUpgrade() {
  localStorage.setItem('mp_is_pro', 'true');
  const modalEl = document.getElementById('proCheckoutModal');
  const modal = bootstrap.Modal.getInstance(modalEl);
  if (modal) modal.hide();

  checkProStatus();
  MarketPulse.checkAuthStatus();
  alert('Congratulations! MarketPulse Pro has been successfully activated!');
}

function cancelProSubscription() {
  if (!confirm('Are you sure you want to cancel your Pro membership? You will return to Free Standard.')) return;
  localStorage.setItem('mp_is_pro', 'false');
  const modalEl = document.getElementById('manageProModal');
  const modal = bootstrap.Modal.getInstance(modalEl);
  if (modal) modal.hide();

  checkProStatus();
  MarketPulse.checkAuthStatus();
  alert('Your membership has been reverted to Free Standard.');
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
