<?php
$pageTitle = 'Access Terminal & Investor Onboarding - MarketPulse';
$currentPage = 'auth';
require_once __DIR__ . '/includes/header.php';
?>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-9 col-xl-8">
            <!-- Header Brand Banner -->
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center bg-primary bg-opacity-10 text-primary p-3 rounded-circle mb-3">
                    <img src="assets/images/logo.png" alt="MarketPulse" width="44" height="44" class="rounded">
                </div>
                <h1 class="h3 fw-bold mb-1">MarketPulse Institutional Gateway</h1>
                <p class="text-muted small">Global market execution, compliance-grade onboarding, and multi-asset intelligence</p>
            </div>

            <!-- Main Auth Card -->
            <div class="mp-card shadow-lg p-4 p-md-5">
                <!-- Navigation Tabs / View Switcher -->
                <ul class="nav nav-pills nav-fill mb-4 p-1 bg-light rounded-3" id="authModeTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active fw-bold py-2" id="nav-login-tab" data-bs-toggle="pill" data-bs-target="#loginViewPane" type="button" role="tab">
                            <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to Terminal
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link fw-bold py-2" id="nav-signup-tab" data-bs-toggle="pill" data-bs-target="#signupViewPane" type="button" role="tab">
                            <i class="bi bi-person-plus-fill me-1"></i> Open Global Account (5 Steps)
                        </button>
                    </li>
                </ul>

                <!-- Alerts -->
                <div id="authAlert" class="alert d-none small mb-4" role="alert"></div>

                <div class="tab-content" id="authModeContent">
                    <!-- ========================================== -->
                    <!-- VIEW 1: SIGN IN PANE                      -->
                    <!-- ========================================== -->
                    <div class="tab-pane fade show active" id="loginViewPane" role="tabpanel">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="small text-muted">Enter your registered investor credentials</span>
                            <button type="button" class="btn btn-sm btn-outline-primary" id="btnQuickDemoLogin">
                                <i class="bi bi-lightning-charge-fill me-1"></i> Quick Demo Autofill
                            </button>
                        </div>

                        <form id="loginForm" novalidate>
                            <div class="mb-3">
                                <label for="loginEmail" class="form-label small fw-semibold">Institutional or Personal Email</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0"><i class="bi bi-envelope text-muted"></i></span>
                                    <input type="email" class="form-control border-start-0" id="loginEmail" placeholder="investor@fund.com" required>
                                </div>
                                <div class="invalid-feedback">Please enter a valid email address.</div>
                            </div>
                            <div class="mb-3">
                                <div class="d-flex justify-content-between">
                                    <label for="loginPassword" class="form-label small fw-semibold">Security Password</label>
                                    <a href="#" class="small text-primary text-decoration-none" onclick="alert('Demo Mode: Temporary password reset link sent to your registered email address.'); return false;">Forgot Password?</a>
                                </div>
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-end-0"><i class="bi bi-lock text-muted"></i></span>
                                    <input type="password" class="form-control border-start-0" id="loginPassword" placeholder="••••••••" required minlength="6">
                                </div>
                                <div class="invalid-feedback">Password must contain at least 6 characters.</div>
                            </div>
                            <div class="mb-4 d-flex justify-content-between align-items-center">
                                <div class="form-check">
                                    <input type="checkbox" class="form-check-input" id="rememberMe" checked>
                                    <label class="form-check-label small text-muted" for="rememberMe">Remember this workstation</label>
                                </div>
                                <span class="badge bg-success-subtle text-success small"><i class="bi bi-shield-check me-1"></i>256-bit TLS Encrypted</span>
                            </div>
                            <button type="submit" class="btn mp-btn-primary w-100 py-2 fw-bold">
                                <i class="bi bi-unlock-fill me-1"></i> Sign In to MarketPulse
                            </button>
                        </form>

                        <div class="text-center mt-4 pt-3 border-top small text-muted">
                            <span>Don't have an institutional brokerage profile yet?</span>
                            <a href="#" class="ms-1 fw-bold text-primary text-decoration-none" id="switchToSignupLink">Start Multi-Step Onboarding &rarr;</a>
                        </div>
                    </div>

                    <!-- ========================================== -->
                    <!-- VIEW 2: MULTI-STEP SIGNUP ONBOARDING FLOW  -->
                    <!-- ========================================== -->
                    <div class="tab-pane fade" id="signupViewPane" role="tabpanel">
                        <!-- Top Progress Bar & Prefill Demo button -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="badge bg-primary-subtle text-primary fw-semibold px-2 py-1" id="stepCounterBadge">Step 1 of 5: Account & Security</span>
                            <button type="button" class="btn btn-sm btn-outline-secondary" id="btnPrefillKycDemo">
                                <i class="bi bi-magic me-1"></i> Prefill Sample KYC
                            </button>
                        </div>

                        <!-- Stepper Visual Indicators -->
                        <div class="mp-stepper-container">
                            <div class="mp-step-item active" id="stepIndicator1">
                                <div class="mp-step-circle">1</div>
                                <span class="mp-step-label">Account</span>
                            </div>
                            <div class="mp-step-item" id="stepIndicator2">
                                <div class="mp-step-circle">2</div>
                                <span class="mp-step-label">Citizenship</span>
                            </div>
                            <div class="mp-step-item" id="stepIndicator3">
                                <div class="mp-step-circle">3</div>
                                <span class="mp-step-label">Financials</span>
                            </div>
                            <div class="mp-step-item" id="stepIndicator4">
                                <div class="mp-step-circle">4</div>
                                <span class="mp-step-label">Objectives</span>
                            </div>
                            <div class="mp-step-item" id="stepIndicator5">
                                <div class="mp-step-circle">5</div>
                                <span class="mp-step-label">Review</span>
                            </div>
                        </div>

                        <!-- Progress Bar -->
                        <div class="progress mb-4" style="height: 6px;">
                            <div class="progress-bar bg-primary progress-bar-striped progress-bar-animated" id="flowProgressBar" role="progressbar" style="width: 20%;"></div>
                        </div>

                        <!-- Multi-Step Form Wizard -->
                        <form id="multiStepSignupForm" novalidate>
                            
                            <!-- STEP 1: ACCOUNT & CREDENTIALS -->
                            <div class="wizard-step" id="wizardStep1">
                                <h5 class="fw-bold mb-1"><i class="bi bi-person-bounding-box text-primary me-2"></i>Account & Security Credentials</h5>
                                <p class="text-muted small mb-4">Provide your legal identity and credentials for your global brokerage account.</p>

                                <div class="row g-3">
                                    <div class="col-12 col-md-6">
                                        <label for="regFullName" class="form-label small fw-semibold">Legal Full Name <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="regFullName" placeholder="e.g. Alex Morgan" required>
                                        <div class="form-text small">Must match passport or official government ID</div>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label for="regEmail" class="form-label small fw-semibold">Institutional / Contact Email <span class="text-danger">*</span></label>
                                        <input type="email" class="form-control" id="regEmail" placeholder="alex.morgan@finance.com" required>
                                        <div class="form-text small">Will be your primary trading login & confirmation ID</div>
                                    </div>

                                    <div class="col-12 col-md-4">
                                        <label for="regPhoneCode" class="form-label small fw-semibold">Country Code</label>
                                        <select class="form-select" id="regPhoneCode">
                                            <option value="+1" selected>🇺🇸 US/CA (+1)</option>
                                            <option value="+44">🇬🇧 UK (+44)</option>
                                            <option value="+49">🇩🇪 Germany (+49)</option>
                                            <option value="+91">🇮🇳 India (+91)</option>
                                            <option value="+81">🇯🇵 Japan (+81)</option>
                                            <option value="+33">🇫🇷 France (+33)</option>
                                            <option value="+41">🇨🇭 Switzerland (+41)</option>
                                            <option value="+65">🇸🇬 Singapore (+65)</option>
                                            <option value="+852">🇭🇰 Hong Kong (+852)</option>
                                            <option value="+61">🇦🇺 Australia (+61)</option>
                                        </select>
                                    </div>
                                    <div class="col-12 col-md-8">
                                        <label for="regPhoneNumber" class="form-label small fw-semibold">Mobile Phone (2FA & Verification) <span class="text-danger">*</span></label>
                                        <input type="tel" class="form-control" id="regPhoneNumber" placeholder="e.g. 555-019-2834" required>
                                    </div>

                                    <div class="col-12 col-md-6">
                                        <label for="regPassword" class="form-label small fw-semibold">Password <span class="text-danger">*</span></label>
                                        <input type="password" class="form-control" id="regPassword" placeholder="Min 8 chars, 1 number, 1 special" required minlength="6">
                                        <div class="mp-strength-bar">
                                            <div class="mp-strength-fill" id="pwdStrengthBar"></div>
                                        </div>
                                        <div class="d-flex justify-content-between small text-muted mt-1">
                                            <span id="pwdStrengthLabel">Strength: None</span>
                                            <span>Min 6+ chars</span>
                                        </div>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label for="regConfirmPassword" class="form-label small fw-semibold">Confirm Password <span class="text-danger">*</span></label>
                                        <input type="password" class="form-control" id="regConfirmPassword" placeholder="Repeat your password" required minlength="6">
                                        <div class="invalid-feedback" id="confirmPwdFeedback">Passwords do not match.</div>
                                    </div>
                                </div>
                            </div>

                            <!-- STEP 2: CITIZENSHIP & REGULATORY TAX RESIDENCY -->
                            <div class="wizard-step d-none" id="wizardStep2">
                                <h5 class="fw-bold mb-1"><i class="bi bi-globe-americas text-primary me-2"></i>Citizenship & Regulatory Tax Residency</h5>
                                <p class="text-muted small mb-4">International trading regulations (SEC, MiFID II, W-8BEN) require verifying legal residency and tax jurisdiction.</p>

                                <div class="row g-3">
                                    <div class="col-12 col-md-6">
                                        <label for="regCitizenship" class="form-label small fw-semibold">Country of Citizenship <span class="text-danger">*</span></label>
                                        <select class="form-select" id="regCitizenship" required>
                                            <option value="United States" selected>🇺🇸 United States</option>
                                            <option value="Germany">🇩🇪 Germany</option>
                                            <option value="United Kingdom">🇬🇧 United Kingdom</option>
                                            <option value="India">🇮🇳 India</option>
                                            <option value="Japan">🇯🇵 Japan</option>
                                            <option value="Switzerland">🇨🇭 Switzerland</option>
                                            <option value="France">🇫🇷 France</option>
                                            <option value="Singapore">🇸🇬 Singapore</option>
                                            <option value="Canada">🇨🇦 Canada</option>
                                            <option value="Australia">🇦🇺 Australia</option>
                                            <option value="Other">🌐 Other International Jurisdiction</option>
                                        </select>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label for="regTaxResidency" class="form-label small fw-semibold">Primary Tax Residency Country <span class="text-danger">*</span></label>
                                        <select class="form-select" id="regTaxResidency" required>
                                            <option value="United States" selected>🇺🇸 United States</option>
                                            <option value="Germany">🇩🇪 Germany</option>
                                            <option value="United Kingdom">🇬🇧 United Kingdom</option>
                                            <option value="India">🇮🇳 India</option>
                                            <option value="Japan">🇯🇵 Japan</option>
                                            <option value="Switzerland">🇨🇭 Switzerland</option>
                                            <option value="France">🇫🇷 France</option>
                                            <option value="Singapore">🇸🇬 Singapore</option>
                                            <option value="Canada">🇨🇦 Canada</option>
                                            <option value="Australia">🇦🇺 Australia</option>
                                            <option value="Other">🌐 Other International Jurisdiction</option>
                                        </select>
                                    </div>

                                    <div class="col-12 col-md-6">
                                        <label for="regDob" class="form-label small fw-semibold">Date of Birth (Must be 18+) <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="regDob" value="1995-06-15" required>
                                        <div class="form-text small">Global securities trading requires age >= 18</div>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label for="regTaxId" class="form-label small fw-semibold">Tax ID / SSN / National Identification <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="regTaxId" placeholder="e.g. XXX-XX-4819 or Tax Number" required>
                                        <div class="form-text small">Used exclusively for tax treaty reporting & FATCA compliance</div>
                                    </div>

                                    <div class="col-12">
                                        <div class="p-3 rounded-3 bg-light border d-flex gap-3 align-items-center">
                                            <i class="bi bi-info-circle-fill text-primary fs-4"></i>
                                            <div class="small text-muted">
                                                <strong>Cross-Border Regulatory Accord:</strong> MarketPulse executes through registered custodian broker-dealers under FINRA/SEC & MiFID II. Your identity data is client-side encrypted and safeguarded.
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- STEP 3: FINANCIAL BACKGROUND & EMPLOYMENT -->
                            <div class="wizard-step d-none" id="wizardStep3">
                                <h5 class="fw-bold mb-1"><i class="bi bi-wallet2 text-primary me-2"></i>Financial Profile & Suitability</h5>
                                <p class="text-muted small mb-4">Required by global broker-dealer suitability rules to evaluate trading appropriateness.</p>

                                <div class="mb-4">
                                    <label class="form-label small fw-semibold d-block mb-2">Employment Status</label>
                                    <div class="row g-2" id="employmentOptions">
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card selected w-100" data-name="employment" data-value="Employed">
                                                <input type="radio" name="employment" value="Employed" checked>
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-briefcase me-1"></i> Employed</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Salaried corporate</div>
                                            </label>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="employment" data-value="Self-Employed">
                                                <input type="radio" name="employment" value="Self-Employed">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-person-workspace me-1"></i> Self-Employed</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Founder / Consultant</div>
                                            </label>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="employment" data-value="Professional Trader">
                                                <input type="radio" name="employment" value="Professional Trader">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-graph-up-arrow me-1"></i> Pro Trader</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Full-time markets</div>
                                            </label>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="employment" data-value="Retired">
                                                <input type="radio" name="employment" value="Retired">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-house-heart me-1"></i> Retired</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Pensions / Annuity</div>
                                            </label>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="employment" data-value="Investor">
                                                <input type="radio" name="employment" value="Investor">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-gem me-1"></i> Private Investor</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Capital assets</div>
                                            </label>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="employment" data-value="Student">
                                                <input type="radio" name="employment" value="Student">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-mortarboard me-1"></i> Student</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Academic learner</div>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mb-4">
                                    <div class="col-12 col-md-6">
                                        <label for="regIndustry" class="form-label small fw-semibold">Industry / Field of Work</label>
                                        <select class="form-select" id="regIndustry">
                                            <option value="Technology & Software" selected>Technology & Software</option>
                                            <option value="Banking & Financial Services">Banking & Financial Services</option>
                                            <option value="Healthcare & Pharmaceuticals">Healthcare & Pharmaceuticals</option>
                                            <option value="Engineering & Manufacturing">Engineering & Manufacturing</option>
                                            <option value="Consulting & Legal">Consulting & Legal</option>
                                            <option value="Energy & Utilities">Energy & Utilities</option>
                                            <option value="Other">Other Global Industries</option>
                                        </select>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label for="regFundSource" class="form-label small fw-semibold">Primary Source of Trading Funds</label>
                                        <select class="form-select" id="regFundSource">
                                            <option value="Employment Income" selected>Employment Income / Salary</option>
                                            <option value="Business Profits">Business Profits</option>
                                            <option value="Personal Savings & Investments">Personal Savings & Investments</option>
                                            <option value="Inheritance & Family Wealth">Inheritance & Family Wealth</option>
                                            <option value="Market Capital Gains">Market Capital Gains</option>
                                        </select>
                                    </div>

                                    <div class="col-12 col-md-6">
                                        <label class="form-label small fw-semibold">Gross Annual Income</label>
                                        <select class="form-select" id="regIncome">
                                            <option value="Under $25,000">Under $25,000</option>
                                            <option value="$25,000 - $50,000">$25,000 - $50,000</option>
                                            <option value="$50,000 - $100,000" selected>$50,000 - $100,000</option>
                                            <option value="$100,000 - $250,000">$100,000 - $250,000</option>
                                            <option value="Over $250,000">Over $250,000</option>
                                        </select>
                                    </div>
                                    <div class="col-12 col-md-6">
                                        <label class="form-label small fw-semibold">Estimated Liquid Net Worth</label>
                                        <select class="form-select" id="regNetWorth">
                                            <option value="Under $50,000">Under $50,000</option>
                                            <option value="$50,000 - $150,000">$50,000 - $150,000</option>
                                            <option value="$150,000 - $500,000" selected>$150,000 - $500,000</option>
                                            <option value="$500,000 - $1,000,000">$500,000 - $1,000,000</option>
                                            <option value="Over $1,000,000">Over $1,000,000</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <!-- STEP 4: INVESTMENT EXPERIENCE & OBJECTIVES -->
                            <div class="wizard-step d-none" id="wizardStep4">
                                <h5 class="fw-bold mb-1"><i class="bi bi-compass text-primary me-2"></i>Trading Experience & Investor Objectives</h5>
                                <p class="text-muted small mb-4">Tailor your terminal access, risk parameters, and order routing preferences.</p>

                                <!-- Experience Level -->
                                <div class="mb-4">
                                    <label class="form-label small fw-semibold d-block mb-2">Equities & Securities Trading Experience</label>
                                    <div class="row g-2" id="expOptions">
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="experience" data-value="Beginner">
                                                <input type="radio" name="experience" value="Beginner">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-seedling text-success me-1"></i> Beginner (&lt; 1 yr)</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Learning fundamental valuations & blue chips</div>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card selected w-100" data-name="experience" data-value="Intermediate">
                                                <input type="radio" name="experience" value="Intermediate" checked>
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="fw-bold small"><i class="bi bi-bar-chart-fill text-primary me-1"></i> Intermediate (1-3 yrs)</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Familiar with technical indicators & earnings</div>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="experience" data-value="Advanced">
                                                <input type="radio" name="experience" value="Advanced">
                                                <span class="mp-choice-check"><i class="bi bi-award-fill text-warning me-1"></i> Advanced (3+ yrs)</div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Active portfolio hedging & derivatives</div>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <!-- Risk Tolerance -->
                                <div class="mb-4">
                                    <label class="form-label small fw-semibold d-block mb-2">Risk Tolerance Profile</label>
                                    <div class="row g-2" id="riskOptions">
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="risk" data-value="Conservative">
                                                <input type="radio" name="risk" value="Conservative">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="fw-bold small">Conservative</span>
                                                    <span class="mp-risk-badge conservative">Low Risk</span>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Capital preservation & steady index growth</div>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card selected w-100" data-name="risk" data-value="Moderate">
                                                <input type="radio" name="risk" value="Moderate" checked>
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="fw-bold small">Moderate</span>
                                                    <span class="mp-risk-badge moderate">Balanced</span>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Balanced growth with standard volatility tolerance</div>
                                            </label>
                                        </div>
                                        <div class="col-12 col-md-4">
                                            <label class="mp-choice-card w-100" data-name="risk" data-value="Aggressive">
                                                <input type="radio" name="risk" value="Aggressive">
                                                <span class="mp-choice-check"><i class="bi bi-check"></i></span>
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <span class="fw-bold small">Aggressive</span>
                                                    <span class="mp-risk-badge aggressive">High Alpha</span>
                                                </div>
                                                <div class="text-muted" style="font-size: 0.72rem;">Max capital growth accepting sharp swings</div>
                                            </label>
                                        </div>
                                    </div>
                                </div>

                                <!-- Preferred Markets -->
                                <div class="mb-3">
                                    <label class="form-label small fw-semibold d-block mb-2">Preferred Global Markets & Assets</label>
                                    <div class="row g-2">
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktUS" value="US Equities (NASDAQ/NYSE)" checked>
                                                <label class="form-check-label small fw-semibold" for="mktUS">🇺🇸 US Equities</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktEU" value="European Blue Chips (DAX/LSE)" checked>
                                                <label class="form-check-label small fw-semibold" for="mktEU">🇪🇺 Europe (DAX/LSE)</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktAsia" value="Asian Markets (Nikkei/Nifty)" checked>
                                                <label class="form-check-label small fw-semibold" for="mktAsia">🇯🇵🇮🇳 Asia (Nikkei/Nifty)</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktETF" value="Global ETFs & Index Funds" checked>
                                                <label class="form-check-label small fw-semibold" for="mktETF">📊 Global ETFs</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktFX" value="Forex & Commodities">
                                                <label class="form-check-label small fw-semibold" for="mktFX">💱 Forex & Gold</label>
                                            </div>
                                        </div>
                                        <div class="col-6 col-md-4">
                                            <div class="form-check form-check-inline p-2 border rounded-3 w-100">
                                                <input class="form-check-input ms-1 me-2" type="checkbox" id="mktCrypto" value="Digital Assets & Web3">
                                                <label class="form-check-label small fw-semibold" for="mktCrypto">⚡ Digital Assets</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- STEP 5: COMPLIANCE, W-8BEN & FINAL REVIEW -->
                            <div class="wizard-step d-none" id="wizardStep5">
                                <h5 class="fw-bold mb-1"><i class="bi bi-shield-lock-fill text-primary me-2"></i>Review & Regulatory Disclosures</h5>
                                <p class="text-muted small mb-3">Please review your investor dossier and confirm mandatory international tax & risk certifications.</p>

                                <!-- Summary Dossier Card -->
                                <div class="card border mb-4 bg-light bg-opacity-50">
                                    <div class="card-header bg-transparent d-flex justify-content-between align-items-center py-2">
                                        <span class="small fw-bold text-primary"><i class="bi bi-file-earmark-person me-1"></i>Investor Dossier Summary</span>
                                        <button type="button" class="btn btn-sm btn-link text-decoration-none py-0" id="btnEditFromSummary">Edit Information</button>
                                    </div>
                                    <div class="card-body p-0">
                                        <table class="table table-sm mb-0 mp-summary-table">
                                            <tbody>
                                                <tr>
                                                    <td class="text-muted" style="width: 35%;">Applicant Name:</td>
                                                    <td class="fw-bold" id="sumFullName">-</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Primary Email:</td>
                                                    <td class="fw-bold" id="sumEmail">-</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Citizenship & Tax Country:</td>
                                                    <td id="sumCitizenship">-</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">National Tax ID:</td>
                                                    <td id="sumTaxId">-</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Employment & Industry:</td>
                                                    <td id="sumEmployment">-</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Experience & Risk Profile:</td>
                                                    <td id="sumProfile">-</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                                <!-- Regulatory Declarations -->
                                <div class="border rounded-3 p-3 mb-3 bg-white">
                                    <div class="form-check mb-3">
                                        <input class="form-check-input" type="checkbox" id="checkW8Ben" required checked>
                                        <label class="form-check-label small" for="checkW8Ben">
                                            <strong>Form W-8BEN / FATCA Tax Treaty Certification:</strong> I certify under penalties of perjury that the person named above is the beneficial owner of the account and the tax declarations submitted are true and correct.
                                        </label>
                                    </div>
                                    <div class="form-check mb-3">
                                        <input class="form-check-input" type="checkbox" id="checkRiskAck" required checked>
                                        <label class="form-check-label small" for="checkRiskAck">
                                            <strong>Global Market Risk Disclosure:</strong> I acknowledge that trading equities, ADRs, and international securities carries the risk of loss of principal. Market valuations fluctuate with geopolitical and foreign exchange movements.
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="checkTerms" required checked>
                                        <label class="form-check-label small" for="checkTerms">
                                            <strong>Electronic Signature & Brokerage Agreement:</strong> I agree to the MarketPulse Master Customer Agreement and Privacy Policy, consenting to electronic delivery of statements and executions.
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- Navigation Buttons -->
                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                                <button type="button" class="btn btn-outline-secondary px-4" id="btnPrevStep" disabled>
                                    <i class="bi bi-arrow-left me-1"></i> Back
                                </button>
                                <button type="button" class="btn mp-btn-primary px-4 fw-bold" id="btnNextStep">
                                    Continue <i class="bi bi-arrow-right ms-1"></i>
                                </button>
                                <button type="submit" class="btn btn-success px-4 fw-bold d-none" id="btnCompleteSignup">
                                    <i class="bi bi-check-circle-fill me-1"></i> Activate Global Account
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="text-center mt-4 pt-2 border-top small text-muted">
                    <span>MarketPulse Global Securities • Institutional Cross-Border Sandbox Node</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ========================================== -->
<!-- SUCCESS / ACTIVATION MODAL                 -->
<!-- ========================================== -->
<div class="modal fade" id="activationSuccessModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content shadow-lg border-0 text-center p-4">
            <div class="mb-3">
                <div class="d-inline-flex align-items-center justify-content-center bg-success bg-opacity-10 text-success p-3 rounded-circle">
                    <i class="bi bi-patch-check-fill fs-1"></i>
                </div>
            </div>
            <h3 class="h4 fw-bold mb-1">Global Brokerage Account Activated!</h3>
            <p class="text-muted small mb-3">Welcome to MarketPulse. Your multi-market institutional profile is verified and active.</p>

            <div class="bg-light p-3 rounded-3 text-start mb-3 border">
                <div class="d-flex justify-content-between mb-2">
                    <span class="small text-muted">Account Number:</span>
                    <span class="small fw-bold text-primary font-monospace" id="modalAccountId">MP-924810-GL</span>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span class="small text-muted">Account Holder:</span>
                    <span class="small fw-bold" id="modalHolderName">Alex Morgan</span>
                </div>
                <div class="d-flex justify-content-between mb-2">
                    <span class="small text-muted">KYC Compliance Tier:</span>
                    <span class="badge bg-success-subtle text-success small">Tier 1 Verified</span>
                </div>
                <div class="d-flex justify-content-between">
                    <span class="small text-muted">Trading Buying Power:</span>
                    <span class="small fw-bold text-success">€100,000.00 / $109,000.00 (Demo Funds)</span>
                </div>
            </div>

            <div class="d-grid gap-2">
                <a href="portfolio.php" class="btn mp-btn-primary py-2 fw-bold">
                    <i class="bi bi-pie-chart-fill me-1"></i> Launch Portfolio Workstation
                </a>
                <a href="index.php" class="btn btn-outline-secondary py-2">
                    <i class="bi bi-graph-up me-1"></i> Explore Live Global Markets
                </a>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const alertBox = document.getElementById('authAlert');

    function showAlert(msg, isSuccess = true) {
        alertBox.className = `alert small mb-4 ${isSuccess ? 'alert-success' : 'alert-danger'}`;
        alertBox.innerHTML = (isSuccess ? '<i class="bi bi-check-circle-fill me-2"></i>' : '<i class="bi bi-exclamation-triangle-fill me-2"></i>') + msg;
        alertBox.classList.remove('d-none');
        window.scrollTo({ top: 120, behavior: 'smooth' });
    }

    // Toggle to Signup from Signin link
    const switchToSignupLink = document.getElementById('switchToSignupLink');
    if (switchToSignupLink) {
        switchToSignupLink.addEventListener('click', (e) => {
            e.preventDefault();
            const signupTab = new bootstrap.Tab(document.getElementById('nav-signup-tab'));
            signupTab.show();
        });
    }

    // Auto switch to signup tab if URL contains #signup or mode=signup
    if (window.location.hash === '#signup' || window.location.search.includes('mode=signup') || window.location.search.includes('tab=signup')) {
        const signupTabEl = document.getElementById('nav-signup-tab');
        if (signupTabEl) {
            const signupTab = new bootstrap.Tab(signupTabEl);
            signupTab.show();
        }
    }

    // Quick Demo Autofill for Login
    const btnQuickDemoLogin = document.getElementById('btnQuickDemoLogin');
    if (btnQuickDemoLogin) {
        btnQuickDemoLogin.addEventListener('click', () => {
            document.getElementById('loginEmail').value = 'alex.morgan@marketpulse.io';
            document.getElementById('loginPassword').value = 'Investor2026!';
            showAlert('Sample institutional investor credentials loaded.', true);
        });
    }

    // -------------------------------------------------------------
    // SIGN IN HANDLER
    // -------------------------------------------------------------
    const loginForm = document.getElementById('loginForm');
    loginForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const email = document.getElementById('loginEmail').value.trim();
        const pass = document.getElementById('loginPassword').value;

        if (!email.includes('@') || !email.includes('.')) {
            document.getElementById('loginEmail').classList.add('is-invalid');
            showAlert('Please enter a valid email address.', false);
            return;
        } else {
            document.getElementById('loginEmail').classList.remove('is-invalid');
        }

        if (pass.length < 6) {
            document.getElementById('loginPassword').classList.add('is-invalid');
            showAlert('Password must contain at least 6 characters.', false);
            return;
        } else {
            document.getElementById('loginPassword').classList.remove('is-invalid');
        }

        const userObj = {
            name: email.split('@')[0].replace('.', ' '),
            email: email,
            accountId: 'MP-' + Math.floor(100000 + Math.random() * 900000) + '-GL',
            authenticated: true,
            kycVerified: true,
            balance: 100000
        };
        localStorage.setItem('mp_user', JSON.stringify(userObj));
        showAlert('Signed in successfully! Launching institutional portfolio...', true);
        setTimeout(() => {
            window.location.href = 'portfolio.php';
        }, 900);
    });

    // -------------------------------------------------------------
    // MULTI-STEP SIGNUP WIZARD LOGIC
    // -------------------------------------------------------------
    let currentStep = 1;
    const totalSteps = 5;

    const stepTitles = [
        "Step 1 of 5: Account & Security",
        "Step 2 of 5: Citizenship & Tax",
        "Step 3 of 5: Financials & Suitability",
        "Step 4 of 5: Objectives & Risk Profile",
        "Step 5 of 5: Review & Compliance Disclosures"
    ];

    const stepCounterBadge = document.getElementById('stepCounterBadge');
    const flowProgressBar = document.getElementById('flowProgressBar');
    const btnPrevStep = document.getElementById('btnPrevStep');
    const btnNextStep = document.getElementById('btnNextStep');
    const btnCompleteSignup = document.getElementById('btnCompleteSignup');

    // Password strength calculation
    const regPassword = document.getElementById('regPassword');
    const pwdStrengthBar = document.getElementById('pwdStrengthBar');
    const pwdStrengthLabel = document.getElementById('pwdStrengthLabel');

    if (regPassword) {
        regPassword.addEventListener('input', () => {
            const val = regPassword.value;
            let score = 0;
            if (val.length >= 6) score += 25;
            if (val.length >= 10) score += 25;
            if (/[0-9]/.test(val)) score += 25;
            if (/[^A-Za-z0-9]/.test(val)) score += 25;

            pwdStrengthBar.style.width = score + '%';
            if (score <= 25) {
                pwdStrengthBar.style.backgroundColor = '#DC2626';
                pwdStrengthLabel.textContent = 'Strength: Weak';
                pwdStrengthLabel.className = 'text-danger small';
            } else if (score <= 50) {
                pwdStrengthBar.style.backgroundColor = '#F59E0B';
                pwdStrengthLabel.textContent = 'Strength: Fair';
                pwdStrengthLabel.className = 'text-warning small';
            } else if (score <= 75) {
                pwdStrengthBar.style.backgroundColor = '#2563EB';
                pwdStrengthLabel.textContent = 'Strength: Good';
                pwdStrengthLabel.className = 'text-primary small';
            } else {
                pwdStrengthBar.style.backgroundColor = '#16A34A';
                pwdStrengthLabel.textContent = 'Strength: Strong';
                pwdStrengthLabel.className = 'text-success small';
            }
        });
    }

    // Card selection binding (radio-like visual cards)
    document.querySelectorAll('.mp-choice-card').forEach(card => {
        card.addEventListener('click', function(e) {
            const groupName = this.getAttribute('data-name');
            if (groupName) {
                document.querySelectorAll(`.mp-choice-card[data-name="${groupName}"]`).forEach(c => {
                    c.classList.remove('selected');
                });
                this.classList.add('selected');
                const radio = this.querySelector('input[type="radio"]');
                if (radio) radio.checked = true;
            }
        });
    });

    // Prefill Sample KYC Button
    const btnPrefillKycDemo = document.getElementById('btnPrefillKycDemo');
    if (btnPrefillKycDemo) {
        btnPrefillKycDemo.addEventListener('click', () => {
            document.getElementById('regFullName').value = 'Alexandra Vance';
            document.getElementById('regEmail').value = 'a.vance@capitalgroup.com';
            document.getElementById('regPhoneNumber').value = '212-555-0149';
            document.getElementById('regPassword').value = 'SecuredTrader2026!';
            document.getElementById('regConfirmPassword').value = 'SecuredTrader2026!';
            document.getElementById('regTaxId').value = 'US-928-11-4091';
            document.getElementById('regDob').value = '1992-04-18';
            document.getElementById('regCitizenship').value = 'United States';
            document.getElementById('regTaxResidency').value = 'United States';
            document.getElementById('regIndustry').value = 'Banking & Financial Services';
            
            // Trigger strength bar update
            regPassword.dispatchEvent(new Event('input'));
            showAlert('Complete sample KYC investor profile populated. You can browse through each step or activate!', true);
        });
    }

    // Step change helper
    function showStep(stepNumber) {
        for (let i = 1; i <= totalSteps; i++) {
            const stepEl = document.getElementById(`wizardStep${i}`);
            const indicatorEl = document.getElementById(`stepIndicator${i}`);
            if (stepEl) {
                stepEl.classList.toggle('d-none', i !== stepNumber);
            }
            if (indicatorEl) {
                indicatorEl.classList.remove('active', 'completed');
                if (i === stepNumber) {
                    indicatorEl.classList.add('active');
                } else if (i < stepNumber) {
                    indicatorEl.classList.add('completed');
                }
            }
        }

        currentStep = stepNumber;
        stepCounterBadge.textContent = stepTitles[stepNumber - 1];
        flowProgressBar.style.width = `${(stepNumber / totalSteps) * 100}%`;

        // Button states
        btnPrevStep.disabled = (currentStep === 1);
        if (currentStep === totalSteps) {
            btnNextStep.classList.add('d-none');
            btnCompleteSignup.classList.remove('d-none');
            populateSummaryReview();
        } else {
            btnNextStep.classList.remove('d-none');
            btnCompleteSignup.classList.add('d-none');
        }

        window.scrollTo({ top: 150, behavior: 'smooth' });
    }

    // Step 1 Validation
    function validateStep1() {
        const name = document.getElementById('regFullName').value.trim();
        const email = document.getElementById('regEmail').value.trim();
        const phone = document.getElementById('regPhoneNumber').value.trim();
        const pass = document.getElementById('regPassword').value;
        const confirm = document.getElementById('regConfirmPassword').value;

        if (!name) {
            showAlert('Please enter your legal full name as shown on official ID.', false);
            document.getElementById('regFullName').focus();
            return false;
        }
        if (!email || !email.includes('@') || !email.includes('.')) {
            showAlert('Please enter a valid email address.', false);
            document.getElementById('regEmail').focus();
            return false;
        }
        if (!phone) {
            showAlert('Please enter your mobile phone number for 2FA validation.', false);
            document.getElementById('regPhoneNumber').focus();
            return false;
        }
        if (pass.length < 6) {
            showAlert('Password must contain at least 6 characters.', false);
            document.getElementById('regPassword').focus();
            return false;
        }
        if (pass !== confirm) {
            showAlert('Passwords do not match. Please verify.', false);
            document.getElementById('regConfirmPassword').focus();
            return false;
        }
        alertBox.classList.add('d-none');
        return true;
    }

    // Step 2 Validation
    function validateStep2() {
        const dobVal = document.getElementById('regDob').value;
        const taxId = document.getElementById('regTaxId').value.trim();

        if (!dobVal) {
            showAlert('Please provide your date of birth.', false);
            return false;
        }
        const birthDate = new Date(dobVal);
        const ageDifMs = Date.now() - birthDate.getTime();
        const ageDate = new Date(ageDifMs);
        const age = Math.abs(ageDate.getUTCFullYear() - 1970);
        if (age < 18) {
            showAlert('International brokerage regulations require account holders to be at least 18 years old.', false);
            return false;
        }
        if (!taxId) {
            showAlert('Please provide your Tax Identification Number (TIN/SSN) for regulatory compliance.', false);
            document.getElementById('regTaxId').focus();
            return false;
        }
        alertBox.classList.add('d-none');
        return true;
    }

    // Step 3 Validation
    function validateStep3() {
        alertBox.classList.add('d-none');
        return true;
    }

    // Step 4 Validation
    function validateStep4() {
        alertBox.classList.add('d-none');
        return true;
    }

    // Populate Summary Review (Step 5)
    function populateSummaryReview() {
        const name = document.getElementById('regFullName').value.trim() || 'Alex Morgan';
        const email = document.getElementById('regEmail').value.trim() || 'investor@marketpulse.io';
        const citizenship = document.getElementById('regCitizenship').value;
        const taxResidency = document.getElementById('regTaxResidency').value;
        const taxId = document.getElementById('regTaxId').value.trim() || 'Pending verification';
        
        const selectedEmp = document.querySelector('input[name="employment"]:checked')?.value || 'Employed';
        const industry = document.getElementById('regIndustry').value;
        const selectedExp = document.querySelector('input[name="experience"]:checked')?.value || 'Intermediate';
        const selectedRisk = document.querySelector('input[name="risk"]:checked')?.value || 'Moderate';

        document.getElementById('sumFullName').textContent = name;
        document.getElementById('sumEmail').textContent = email;
        document.getElementById('sumCitizenship').textContent = `${citizenship} (Tax Res: ${taxResidency})`;
        document.getElementById('sumTaxId').textContent = taxId.replace(/.(?=.{4})/g, '•'); // Masked for security
        document.getElementById('sumEmployment').textContent = `${selectedEmp} • ${industry}`;
        document.getElementById('sumProfile').textContent = `${selectedExp} Experience • ${selectedRisk} Risk`;
    }

    // Next Step Button
    btnNextStep.addEventListener('click', () => {
        if (currentStep === 1 && !validateStep1()) return;
        if (currentStep === 2 && !validateStep2()) return;
        if (currentStep === 3 && !validateStep3()) return;
        if (currentStep === 4 && !validateStep4()) return;

        if (currentStep < totalSteps) {
            showStep(currentStep + 1);
        }
    });

    // Previous Step Button
    btnPrevStep.addEventListener('click', () => {
        if (currentStep > 1) {
            showStep(currentStep - 1);
        }
    });

    // Edit from Summary
    const btnEditFromSummary = document.getElementById('btnEditFromSummary');
    if (btnEditFromSummary) {
        btnEditFromSummary.addEventListener('click', () => {
            showStep(1);
        });
    }

    // -------------------------------------------------------------
    // COMPLETE REGISTRATION HANDLER
    // -------------------------------------------------------------
    const multiStepSignupForm = document.getElementById('multiStepSignupForm');
    multiStepSignupForm.addEventListener('submit', (e) => {
        e.preventDefault();

        // Check required disclosures
        const w8 = document.getElementById('checkW8Ben').checked;
        const risk = document.getElementById('checkRiskAck').checked;
        const terms = document.getElementById('checkTerms').checked;

        if (!w8 || !risk || !terms) {
            showAlert('Please acknowledge all mandatory regulatory, W-8BEN, and brokerage disclosure checkboxes.', false);
            return;
        }

        const name = document.getElementById('regFullName').value.trim();
        const email = document.getElementById('regEmail').value.trim();
        const citizenship = document.getElementById('regCitizenship').value;
        const taxResidency = document.getElementById('regTaxResidency').value;
        const phone = document.getElementById('regPhoneCode').value + ' ' + document.getElementById('regPhoneNumber').value.trim();
        const income = document.getElementById('regIncome').value;
        const netWorth = document.getElementById('regNetWorth').value;
        const employment = document.querySelector('input[name="employment"]:checked')?.value || 'Employed';
        const industry = document.getElementById('regIndustry').value;
        const experience = document.querySelector('input[name="experience"]:checked')?.value || 'Intermediate';
        const riskTolerance = document.querySelector('input[name="risk"]:checked')?.value || 'Moderate';

        // Gather preferred markets
        const preferredMarkets = [];
        ['mktUS', 'mktEU', 'mktAsia', 'mktETF', 'mktFX', 'mktCrypto'].forEach(id => {
            const cb = document.getElementById(id);
            if (cb && cb.checked) preferredMarkets.push(cb.value);
        });

        const generatedAccountId = 'MP-' + Math.floor(100000 + Math.random() * 900000) + '-GL';

        // Full comprehensive profile
        const userProfile = {
            name: name,
            email: email,
            phone: phone,
            citizenship: citizenship,
            taxResidency: taxResidency,
            employment: employment,
            industry: industry,
            annualIncome: income,
            netWorth: netWorth,
            experience: experience,
            riskTolerance: riskTolerance,
            preferredMarkets: preferredMarkets,
            accountId: generatedAccountId,
            kycVerified: true,
            authenticated: true,
            tier: 'Verified Global Investor',
            virtualBalance: 100000,
            onboardedAt: new Date().toISOString()
        };

        // Persist
        localStorage.setItem('mp_user', JSON.stringify(userProfile));
        localStorage.setItem('mp_investor_profile', JSON.stringify(userProfile));

        // Show Modal
        document.getElementById('modalAccountId').textContent = generatedAccountId;
        document.getElementById('modalHolderName').textContent = name;

        const modalEl = document.getElementById('activationSuccessModal');
        const modal = new bootstrap.Modal(modalEl);
        modal.show();
    });
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
