# Visit Proof: Figma Design Brief

## 0. Instructions for the designer (Claude)

You are designing the **Visit Proof** mobile app in Figma. It is a field-service app: an office admin plans visits and sends technicians to client sites, and technicians prove each visit with their live location and camera photos. This brief describes **every screen that exists today**, read from the app's code. Your job is a better-looking, clearer design of the same product.

**Rules**
1. **Keep every function.** Each field, button, state and rule listed here must exist in your design. You may regroup, restyle and rename for clarity, but do not drop anything.
2. **Phone first.** Main frame: **390 × 844** (iPhone 14). Also make a **1280 × 800** desktop frame for the two screens that adapt to wide screens: Dashboard (DSH-1) and Dispatch (DSP-1).
3. **Two languages.** Every label below is given as `"English" / "العربية"`. Design the key screens in **English (left-to-right)** and in **Arabic (right-to-left, mirrored)**. Arabic uses Western digits (0–9). Phone numbers always read left-to-right.
4. **Light and dark mode.** Build all colors as Figma variables with a Light and a Dark mode.
5. **Customers re-brand the app.** Each company can change 8 colors, the fonts, the text size (85%–125%), the app name and the icon or logo. So:
   - use color variables only, never hard-coded colors;
   - put the app name and logo in a single component;
   - make layouts hold up at 125% text size.
6. **Status colors carry meaning.** Visit status, payment status and priority each have a fixed color (section 2). Never use color alone: pair it with text and an icon.
7. **Use the sample data** in section 4 so screens look real.
8. **Out of scope:** the Wizpo sales website and design studio. Design only the app.

**What to deliver** (full list in section 7)
1. A **Foundations** page: color variables, type scale, spacing, radius and elevation.
2. A **Components** page with variants.
3. One page per area with the frames listed: Auth, Admin shell, Technician, Visits, Visit details, Dispatch, Dashboard, Invoices, Directory, Shared.
4. A clickable prototype for the four main flows in section 8.

## 1. Product in one page

**Roles**
- **Admin.** No password: one tap on the first screen. Uses the whole app through a side drawer with 8 sections in 3 groups.
- **Technician.** Signs in with the email and password the admin created. Sees only their own visits. Can move a visit forward, add notes and collect payment. Every technician action needs their live location, a consent tick, and sometimes camera photos.
- Either role can switch to the other from the drawer.

**Navigation model**
- **Admin:** a side drawer (no bottom navigation) switches between "Dashboard" / "لوحة التحكم", "Dispatch" / "التوزيع", "Visits" / "الزيارات", "Invoices" / "الفواتير", "Collections" / "التحصيلات", "Clients" / "العملاء", "Technicians" / "الفنيون" and "Services" / "الخدمات". Detail screens are pushed on top with a back arrow. Most edits happen in **bottom sheets** that slide over the current screen.
- **Technician:** one home list ("My Visits" / "زياراتي") and a drawer. Visit details opens on top; actions open as bottom sheets.

**Visit lifecycle** (the heart of the app)

"Draft" / "مسودة" → "Scheduled" / "مجدولة" → "Assigned" / "مُسندة" → "On The Way" / "في الطريق" → "In Progress" / "قيد التنفيذ" → "Completed" / "مكتملة", with "Cancelled" / "ملغاة" possible from anywhere before completion.

- Assigning a technician moves a visit to "Assigned" / "مُسندة".
- The technician presses "Start trip" / "بدء التنقل", then "Start work" / "بدء العمل" (must be within 200 m of the site), then "Complete visit" / "إكمال الزيارة".
- Completing auto-issues the invoice. The technician may then "Collect payment" / "تحصيل الدفعة" with a receipt photo, and the admin confirms or rejects it in "Collections" / "التحصيلات".

**There are no push notifications and no live updates.** Data refreshes on pull-to-refresh, on returning to a screen, or after an action. Do not design notification badges or live technician tracking. Those features do not exist.

## 2. Foundations (current values, as a starting point)

You may refine these. Keep the token names, because the code and the customer branding use them.

### Color variables
| Token | Light | Dark | Role |
|---|---|---|---|
| `primary` | #6C5CE7 | #8E80F7 | Main brand: buttons, links, selection |
| `secondary` | #00CEC9 | #2EDBD6 | Second brand: gradients, section icons |
| `onPrimary` | #FFFFFF | #FFFFFF | Text and icons on brand colors |
| `scaffoldBackground` | #F4F6F9 | #12141C | Screen background |
| `surface` | #FFFFFF | #1C1F2A | Sheets, panels |
| `cardColor` | #FFFFFF | #1C1F2A | Cards |
| `searchFieldBg` | #FFFFFF | #232736 | Inputs |
| `locationChipBg` | #F1F2F6 | #262A38 | Soft fills, chips |
| `textPrimary` | #2C3E50 | #E8EAF1 | Main text |
| `textSecondary` | #8B93A6 | #9AA1B5 | Secondary text |
| `textDarkHint` | #636E72 | #B7BDCC | Hints |
| `textLightHint` | #A0A5B9 | #717889 | Placeholders |
| `iconGrey` | #8B93A6 | #9AA1B5 | Icons |
| `iconLightGrey` | #B2BEC3 | #4A5063 | Borders, dividers |
| `statGreen` | #00B894 | #1AAE85 | Success, paid, completed |
| `pending` | #FFA000 | #FFB84D | Waiting, scheduled |
| `statOrange` | #E17055 | #FF8A70 | Danger, cancelled, errors |
| `whatsappGreen` | #00B894 | #25D366 | WhatsApp |
| `shadowColor` | black 3% | black 20% | Shadows |

**Customer-editable slots:** primary, secondary, background, card, text, success (statGreen), waiting (pending) and danger (statOrange). Background, card and text change light mode only.

### Status → color (fixed meaning)
| Group | Value → token |
|---|---|
| Visit status | "Draft" / "مسودة" iconGrey · "Scheduled" / "مجدولة" pending · "Assigned" / "مُسندة" primary · "On The Way" / "في الطريق" secondary · "In Progress" / "قيد التنفيذ" pending · "Completed" / "مكتملة" statGreen · "Cancelled" / "ملغاة" statOrange |
| Payment status | "Unpaid" / "غير مدفوعة" textLightHint · "Pending" / "قيد الانتظار" pending · "Partially Paid" / "مدفوعة جزئيًا" primary · "Paid" / "مدفوعة" statGreen · "Cancelled" / "ملغاة" statOrange · "Refunded" / "مستردة" secondary |
| Priority | "Emergency" / "طارئة" statOrange · "High" / "عالية" secondary · "Normal" / "عادية" primary · "Low" / "منخفضة" iconGrey |
| Technician | "Available" / "متاح" statGreen · "Busy" / "مشغول" pending · "Offline" / "غير متصل" iconGrey |
| Photo kind | "Before work" / "قبل العمل" pending · "After work" / "بعد العمل" statGreen · "With a note" / "مع ملاحظة" secondary · "Payment receipt" / "إيصال الدفع" primary |
| Ledger entry | "Confirmed" / "مؤكد" statGreen · "Awaiting confirmation" / "بانتظار التأكيد" pending · "Rejected" / "مرفوض" statOrange |

Scheduled and In progress share one color today. Consider giving them different colors (as tokens) in your design.

### Type
Fonts: **Manrope** (English), **Cairo** (Arabic).

| Token | Size | Use |
|---|---|---|
| micro | 10 | Chart axes, tiny badges |
| caption | 11.5 | Hints, timestamps |
| small | 12 | Chips, subtitles |
| body | 13 | Regular text |
| bodyLarge | 14 | Inputs, important rows |
| subtitle | 15 | Button labels |
| title | 16 | Card titles |
| titleLarge | 18 | App bar titles |
| headline | 20 | Screen headlines |
| display | 26 | KPI numbers, amounts |

Weights used: 800 (titles, numbers), 700, 600, 500.

### Spacing, radius, elevation
- **Spacing:** values in use are 4, 6, 8, 10, 12, 14, 16, 20, 24. Screen side padding is 16–20. Propose a 4-pt scale.
- **Radius:** cards 16–20, inputs and buttons 12–15, chips and pills 100 (fully rounded), sheets 24 at the top.
- **Elevation:** soft shadows, blur 8–15, low opacity. Cards also use a 1 px light border.

### Icons
Material Symbols, Rounded style. Plus a WhatsApp logo asset.

## 3. Component library (build these with variants)

| Component | Variants / parts | Used in |
|---|---|---|
| **Button** | filled (primary), gradient (primary→secondary), outlined, danger outlined (statOrange), text; × enabled / disabled / loading; optional leading icon | Everywhere |
| **Floating action button** | extended, label only, frosted gradient | VIS-1, CLI-1, TEC-1, SVC-1 |
| **"Add" link** | ⊕ icon + text, inline under a field | VIS-3, VD-3, VD-7 |
| **Text field** | label, placeholder, prefix icon, suffix icon, error text, character counter; × empty / filled / focused / error / disabled | Forms |
| **Multiline field** | same, 3–5 lines | Problem, notes, reason |
| **Tap-to-pick field** | read-only field with a calendar or clock icon that opens a picker | Dates and times |
| **Dropdown** | label, selected value, chevron, loading spinner; open state = floating list with an optional search box, checkmark on the selected row, empty text "No results found" / "لا توجد نتائج" | Pickers |
| **Phone field** | country flag + code (opens country search "Search country..." / "ابحث عن دولة..."), number; always LTR | Client, technician |
| **Search bar** | search icon, placeholder, clear ✕ | Lists |
| **Filter button** | tune icon + count badge | VIS-1, INV-1 |
| **Choice chip** | unselected / selected (with ✓), takes a color | Filters, periods, priority |
| **Status pill** | small rounded label, tinted background, optional icon; one variant per status in section 2; "on-dark" variant for gradients | Cards, headers |
| **Switch row** | title, subtitle, switch | Photo requirements, settings |
| **Checkbox row** | checkbox + paragraph | Consent |
| **Section card** | colored 4 px top strip, icon tile, title, optional header action chip (e.g. "Edit" / "تعديل"), body | Visit details |
| **Action chip** | icon + label, outlined, tinted | "Call" / "اتصال", "Map" / "الخريطة", "Reassign" / "إعادة إسناد" |
| **Stat tile** | icon, value, label | Schedule, dispatch |
| **Info line** | label ··· value (value can be emphasized or colored) | Invoice breakdown |
| **Notice** | icon + text on a tinted background; info / success / warning / blocking | Rules and hints |
| **Avatar** | initial letter on a 2-color gradient circle | People |
| **Empty state** | gradient icon tile, title, subtitle, optional gradient button | Lists |
| **Inline empty** | grey icon + one line | Inside cards |
| **Loading** | full overlay (dimmed content + spinner), inline spinner | All |
| **Toast** | floating bar: success (green) / error (red) | After actions |
| **Bottom sheet** | handle, title, close ✕, optional subtitle, scrolling body, primary button at the bottom | All edits |
| **Dialog** | icon (optional), title, text, 2 buttons; "delete" variant with warning icon + "Cancel" / "إلغاء" / "Delete" / "حذف" | Confirms |
| **Section app bar** | ☰ menu button, section icon, title, optional right actions | Drawer sections |
| **Pushed header** | ‹ back, centered or leading title, rounded bottom corners | Detail screens |
| **Drawer** | gradient header, grouped items (icon tile, label, hint, selected state), footer with settings and account actions | ADM-1, TECH-2 |
| **Settings card** | "Language" / "اللغة" row with English / العربية segmented toggle; "Dark mode" / "الوضع الداكن" row with switch | Drawers, role screen |
| **Timeline item** | colored dot + line, title, "date · actor · role", optional location chip, optional quoted reason | Visit activity |
| **Photo thumbnail** | square image, remove ✕ (editable variant), broken-image fallback; "add photo" tile with camera icon + "Add" / "إضافة" | Proof photos |
| **Map preview** | empty ("Pick from map" / "اختر من الخريطة") / static map with pin + "Edit" / "تعديل" badge | Site forms |
| **Progress bar** | thin bar for paid/total and workload | Invoices, dispatch |
| **KPI card** | icon tile, label, big value, caption, delta (↑ green / ↓ red / "No change" / "بدون تغيير"), chevron, alert border | Dashboard |
| **Bar chart** | stacked bars (completed / not completed) or single (money), tap to select, readout row, legend | Dashboard |
| **Bar list row** | label, value, horizontal bar, selected / dimmed | Dashboard |

**Cards** (also components, detailed in section 5): Visit card, Dispatch visit card, Technician board card, Invoice card, Payment tile, Client card, Technician card, Service card, Client-history visit card.

## 4. Sample content

| Kind | Examples |
|---|---|
| Company | HVAC company in Riyadh |
| Technicians | Ahmed Saleh / أحمد صالح (HVAC), Omar Khalid / عمر خالد (HVAC, Electrical), Youssef Ali / يوسف علي (Plumbing), Fahad Alqahtani / فهد القحطاني, Khalid Alharbi / خالد الحربي |
| Clients | Al Noor Pharmacy / صيدلية النور, Najd Bakery / مخبز نجد, Coastal Hotel / فندق الساحل, Sara Villa / فيلا سارة, Faisal Residence / منزل فيصل |
| Address | Riyadh – Olaya St / الرياض – شارع العليا |
| Categories | HVAC, Electrical, Plumbing, Carpentry, Networking, Smart Home |

Services:
- AC periodic maintenance / صيانة دورية للمكيف · 250 SAR · 60 min · tasks: Clean filters, Check refrigerant pressure, Clean drain line, Test thermostat
- AC fault repair / إصلاح عطل مكيف · 400 SAR · 90 min
- Split AC installation / تركيب مكيف سبليت · 650 SAR · 180 min
- Electrical panel inspection / فحص اللوحة الكهربائية · 300 SAR · 60 min
- Water leak repair / إصلاح تسريب مياه · 200 SAR · 60 min

Formats:
| Item | Format | Example |
|---|---|---|
| Visit number | `VIS-000124` | VIS-000124 |
| Invoice number | `INV-000124` | INV-000124 |
| Money | 2 decimals + currency | `250.00 SAR` |
| Dashboard money | short | `12.3K SAR` |
| Date | `dd MMM yyyy` | 05 Nov 2026 |
| Time | `hh:mm a` | 09:30 AM |
| Date and time | `dd MMM yyyy · hh:mm a` | 05 Nov 2026 · 09:30 AM |
| Distance | metres under 1 km, then km | `18 m`, `1.2 km` |
| Duration | | `1 h 30 min` |
| Demo technician sign-in | | ahmed@demo.com / 123456 |

## 5. Screens

Each screen gives:
- its ID, type (full screen, bottom sheet or dialog) and role;
- where it opens from;
- the **layout tree** from top to bottom;
- the **states and variants** to draw;
- what each action does.

`→` means "opens". Items marked *(if …)* appear only under that condition.

---

### Area A · Entry and shells

#### AUTH-2 · Role Select
Full screen · everyone with no session.

**Layout**
- No app bar. Centered scrolling column.
  1. Brand block: rounded gradient tile (primary → secondary) with the app icon or logo, app name ("Visit Proof" / "Visit Proof" by default, customer's name otherwise), tagline "Field visits with proof of work" / "زيارات ميدانية مع إثبات العمل".
  2. Heading "How do you want to continue?" / "كيف تريد المتابعة؟" + hint "You can switch roles later from the app menu." / "يمكنك تغيير الدور لاحقًا من قائمة التطبيق."
  3. Role card, admin: icon tile, "Admin" / "المسؤول", "Plan visits, dispatch technicians and follow invoices." / "خطط الزيارات ووزّع الفنيين وتابع الفواتير.", chevron.
  4. Role card, technician: "Technician" / "الفني", "See your visits, check in on site and add proof photos." / "اطّلع على زياراتك وسجّل وصولك للموقع وأضف صور الإثبات.", chevron.
  5. Settings card (component).

**States:** default; admin card loading (spinner replaces the chevron).

**Actions:** Admin → ADM-1 (no password). Technician → AUTH-3.

#### AUTH-3 · Technician Sign In
Full screen · technician.

**Layout**
- Pushed header "Technician sign in" / "تسجيل دخول الفني".
  1. Large engineer icon, "Welcome back" / "مرحبًا بعودتك", "Use the email and password your admin created for you." / "استخدم البريد الإلكتروني وكلمة المرور اللذين أنشأهما لك المسؤول."
  2. Field "Email Address" / "البريد الإلكتروني", placeholder "name@company.com", @ icon.
  3. Field "Password" / "كلمة المرور", lock icon, eye toggle.
  4. Button "Sign in" / "تسجيل الدخول".
  5. Small text "Forgot your password? Ask your admin to set a new one." / "نسيت كلمة المرور؟ اطلب من المسؤول تعيين كلمة جديدة."

**States:** empty; filled; field errors ("Please enter a valid email address" / "يرجى إدخال بريد إلكتروني صحيح", "Please enter your password" / "يرجى إدخال كلمة المرور"); loading; error toast "Wrong email or password." / "البريد الإلكتروني أو كلمة المرور غير صحيحة."

**Actions:** Sign in → TECH-1 with toast "Welcome, {0}" / "أهلًا، {0}".

#### AUTH-4 · Log Out (dialog)
- Red logout icon, "Log out?" / "تسجيل الخروج؟", "You will need to sign in again to use the app." / "ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام التطبيق."
- Buttons: "Cancel" / "إلغاء" and "Log out" / "تسجيل الخروج".

#### ADM-1 · Admin Drawer and Shell
Shell · admin. Every admin section is a full screen with the ☰ button opening this drawer.

**Drawer layout**
1. Gradient header with a rounded bottom corner: brand mark, app name, "Admin" / "المسؤول".
2. Group "Operations" / "العمليات" (uppercase label):
   - "Dashboard" / "لوحة التحكم", hint "Overview and what needs attention" / "نظرة عامة وما يحتاج إلى متابعة"
   - "Dispatch" / "التوزيع", hint "Assign and schedule technicians" / "إسناد الفنيين وجدولتهم"
   - "Visits" / "الزيارات", hint "Every visit and its status" / "كل الزيارات وحالاتها"
3. Group "Finance" / "المالية":
   - "Invoices" / "الفواتير", hint "Billing, payments and refunds" / "الفواتير والمدفوعات والاستردادات"
   - "Collections" / "التحصيلات", hint "Field payments to confirm" / "مدفوعات ميدانية بانتظار التأكيد"
4. Group "Directory" / "الدليل":
   - "Clients" / "العملاء", hint "Customers, sites and equipment" / "العملاء والمواقع والمعدات"
   - "Technicians" / "الفنيون", hint "Your field team" / "فريقك الميداني"
   - "Services" / "الخدمات", hint "Prices, durations and checklists" / "الأسعار والمدد وقوائم التحقق"
5. Each row: icon tile, label, hint. Selected row: tinted background, filled icon tile in primary, label in primary.
6. Footer: settings card, then account rows "Switch to technician" / "التبديل إلى فني" (engineer icon) and "Log out" / "تسجيل الخروج" (red).

**States:** drawer closed / open; each item selected once (draw Dashboard selected).

**Actions:** row → swaps the section. "Switch to technician" / "التبديل إلى فني" → AUTH-3. "Log out" / "تسجيل الخروج" → AUTH-4. Back on any section returns to Dashboard.

**Design opportunity:** "Collections" / "التحصيلات" is a to-do queue but has no count badge today. You may add a count badge; the data exists.

#### TECH-1 · My Visits (technician home)
Full screen · technician.

**Layout**
- Section app bar: ☰, engineer icon, "My Visits" / "زياراتي".
- Scroll (pull to refresh):
  1. Greeting card (gradient): "Hi, {0}" / "مرحبًا، {0}" with the technician's name, today's date (`Wednesday, 05 Nov 2026`), big number of open visits + "open visits" / "زيارات مفتوحة".
  2. *(if a visit is on the way or in progress)* Current job card, outlined in the status color: status icon, "Current job · {0}" / "المهمة الحالية · {0}" (status), "service · client", chevron.
  3. Filter chips with counts "{0} ({1})" / "{0} ({1})": "Open" / "مفتوحة" (default), "Today" / "اليوم", "Completed" / "مكتملة", "All" / "الكل".
  4. Visit cards (same Visit card as VIS-1).

**States:**
- Loading.
- With current job.
- Without current job.
- Empty, none assigned: "No visits assigned to you yet" / "لا توجد زيارات مسندة إليك بعد" / "Your admin assigns visits to you. Pull down to refresh." / "يسند إليك المسؤول الزيارات. اسحب للأسفل للتحديث."
- Empty, filter: "Nothing in this list" / "لا يوجد شيء في هذه القائمة" / "Try another filter." / "جرّب عامل تصفية آخر."

**Actions:** card or current job → VD-1. Chip filters. ☰ → TECH-2.

#### TECH-2 · Technician Drawer
1. Gradient header: initial avatar, name, email.
2. Two tip cards:
   - location icon + "Every action you take records your current location for the admin." / "كل إجراء تقوم به يسجّل موقعك الحالي ليراه المسؤول."
   - camera icon + "Take before and after photos when the visit asks for them." / "التقط صور ما قبل العمل وما بعده عندما تطلبها الزيارة."
3. Footer: settings card, "Switch to admin" / "التبديل إلى المسؤول", "Log out" / "تسجيل الخروج".

#### COMP-1 · Settings Card
- Row 1: translate icon, "Language" / "اللغة", segmented toggle "English" | "العربية" (each written in its own language).
- Divider.
- Row 2: moon/sun icon, "Dark mode" / "الوضع الداكن", switch.
- **Variant:** without the dark-mode row (installed PWAs lock the theme).

#### COMP-2 · Install Bar (installed web app opened in a browser)
- Solid primary bar across the top: download icon, "Install this app on your device." / "ثبّت هذا التطبيق على جهازك.", "Install" / "تثبيت", ✕.
- iPhone variant: share icon, "To install, tap Share and then "Add to Home Screen"." / "للتثبيت، اضغط على زر المشاركة ثم اختر «إضافة إلى الشاشة الرئيسية».", ✕ only.
- Low priority; one frame is enough.

---

### Area B · Visits

#### VIS-1 · Visits List
Full screen · admin.

**Layout**
- Section app bar: ☰, checklist icon, "Visits" / "الزيارات", right: gradient button "Dispatch" / "التوزيع" with hub icon.
- Row: search "Search visit number, client, service..." / "ابحث برقم الزيارة أو العميل أو الخدمة..." + filter button with count badge.
- List of **Visit cards** (pull to refresh).
- Floating button "Add New Visit" / "إضافة زيارة جديدة".

**Visit card**
1. Row: visit number (bold), calendar icon + date-time, status pill (uppercase).
2. Two-column row: person icon + client name ("no client" / "بدون عميل"); service icon + category ("no category" / "بدون فئة").
3. Engineer icon + technician ("no technician assigned" / "لم يُسند فني").
4. Pin icon + "City - address".
5. *(if any)* Problem text, 2 lines.
6. Row of small pills: priority, payment status. Trailing chevron.

**States:**
- Loading.
- List.
- Empty: "No visits yet" / "لا توجد زيارات بعد" / "Create your first visit to start tracking field work." / "أنشئ أول زيارة لتبدأ متابعة العمل الميداني." / "Add first visit" / "أضف أول زيارة"
- No match: "No matching visits" / "لا توجد زيارات مطابقة" / "Try another search or clear the filters." / "جرّب بحثًا آخر أو امسح التصفية." / "Clear search & filters" / "مسح البحث والتصفية"
- Filter badge showing "3".

**Actions:** card → VD-1. Dispatch → DSP-1. Filter → VIS-2. FAB → VIS-3.

#### VIS-2 · Filter Visits (sheet)
- Title "Filter visits" / "تصفية الزيارات", subtitle "Pick one or more options in each group" / "اختر خيارًا أو أكثر في كل مجموعة".
- Group "Visit status" / "حالة الزيارة": 7 chips.
- Group "Payment" / "الدفع": 6 chips.
- Group "Priority" / "الأولوية": 4 chips.
- Bottom row: outlined "Reset" / "إعادة ضبط" + filled "Apply" / "تطبيق".
- **States:** none selected; some selected.

#### VIS-3 · Add Visit
Full screen · admin. A long form in three titled cards with a sticky footer.

**Layout**
- Pushed header "Add Visit" / "إضافة زيارة".
- Card 1 "Client & Site" / "العميل والموقع" (person-pin icon):
  - Searchable dropdown "Client" / "العميل" (search "Search for client" / "ابحث عن عميل").
  - Add link "Add New Client" / "إضافة عميل جديد".
  - *(after a client is chosen)* Dropdown "Site" / "الموقع" showing "City - address", plus a small "Update\nSite" / "تحديث\nالموقع" button *(if a site is chosen)*, then add link "Add New Site" / "إضافة موقع جديد".
- Card 2 "Service" / "الخدمة" (wrench icon):
  - Searchable dropdown "Service" / "الخدمة"; each row shows the name and the category in small text.
  - Add link "Add New Service" / "إضافة خدمة جديدة".
  - *(after a service is chosen)* **Service summary card**: category chip, price `250.00 SAR`, service name, checklist box (✓ per task), footer chips "{0} Min" / "{0} دقيقة" and "{0} Task{1}" / "{0} مهام", text button "Update" / "تحديث".
  - Switch row "Require Before-Work Photos" / "طلب صور ما قبل العمل" / "Technician supplies proof during the visit" / "يقدّم الفني الإثبات أثناء الزيارة".
  - Switch row "Require After-Work Photos" / "طلب صور ما بعد العمل" / same subtitle.
- Card 3 "Scheduling & Assignment" / "الجدولة والإسناد" (assignment icon):
  - Searchable dropdown "Technician" / "الفني" (optional), add link "Add New Technician" / "إضافة فني جديد".
  - Dropdown "Priority" / "الأولوية" (default Normal).
  - Tap-to-pick "Start Date" / "تاريخ البدء" (calendar icon).
  - Tap-to-pick "Start Time" / "وقت البدء" (clock icon), placeholder "00:00 AM/PM" / "00:00 ص/م".
  - Multiline "Problem" / "المشكلة" (max 1000), placeholder "e.g., AC unit in the master bedroom is blowing warm air. The outdoor compressor is making a loud buzzing noise...." / "مثال: مكيف غرفة النوم الرئيسية يخرج هواءً ساخنًا، والضاغط الخارجي يصدر صوتًا عاليًا...."
  - Multiline "Notes" / "ملاحظات" (max 250), placeholder "e.g., Gate code is 1234, call 10 mins before arrival..." / "مثال: رمز البوابة 1234، اتصل قبل الوصول بـ10 دقائق..."
- Sticky frosted footer:
  - Outlined grey "Save Draft" / "حفظ كمسودة" + filled "Schedule" / "جدولة".
  - When a technician is chosen, the filled button reads "Assigned" / "مُسندة", the footer turns amber-tinted, and the tip "Tip: Since you've already chosen a technician, the 'Schedule' button has updated to 'Assigned'" / "تلميح: بما أنك اخترت فنيًا، تغيّر زر "جدولة" إلى "مُسندة"" appears.

**States to draw:**
1. Empty form.
2. Completed form, no technician.
3. With technician (amber footer + tip).
4. Validation: red "This field is required to {0}" / "هذا الحقل مطلوب لـ{0}" under client, site, service, date and time; "Start time must be in the future" / "يجب أن يكون وقت البدء في المستقبل".
5. Saving (spinner in the pressed button).

**Actions:**
- Add New Client → CLI-3. Add/Update Site → VIS-4. Add New Service / Update → SVC-2. Add New Technician → TEC-3.
- Save Draft saves without checks. Schedule / Assigned checks all required fields and saves.

**Design opportunity:** "Assigned" is a status, not a verb. Consider "Assign" / "إسناد"-style wording such as "Schedule & assign" (new text needs a translation).

#### VIS-4 · Add / Update Site (sheet)
- Title "Add new site" / "إضافة موقع جديد" or "Update Site" / "تحديث الموقع".
- Searchable dropdown "Select City *" / "اختر المدينة *" (city icon).
- Label "Address Configuration" / "إعداد العنوان".
- **Map + address block:**
  - map preview: empty "Pick from map" / "اختر من الخريطة", or a static map with a pin and an "Edit" / "تعديل" badge;
  - field "Detailed Address" / "العنوان التفصيلي", placeholder "Building, Street, Area..." / "المبنى، الشارع، الحي..."
- Button "Add new Site" / "إضافة موقع جديد" / "Update Site" / "تحديث الموقع".
- **Errors:** "City is required" / "المدينة مطلوبة", "Please provide an address detail or pick a location from the map." / "يرجى إدخال تفاصيل العنوان أو تحديد الموقع على الخريطة.", "Detailed address must be at least 10 characters long" / "يجب ألا يقل العنوان التفصيلي عن 10 أحرف".
- Map → MAP-2.

---

### Area C · Visit details (the most important screen)

#### VD-1 · Visit Details
Full screen · admin and technician. The same screen shows different actions by role and status.

**Layout**
- Pushed header "Visit Details" / "تفاصيل الزيارة".
- Scroll (pull to refresh), a stack of cards:

1. **Hero card** (gradient primary → secondary; red/amber gradient when cancelled)
   - Row: glass chip "# VIS-000124", status pill (on-dark variant, with icon).
   - Service name, large ("No service selected" / "لم يتم اختيار خدمة" if empty).
   - Category icon + category ("Uncategorized" / "بدون فئة").
   - Three glass stat boxes: "Price" / "السعر" `250.00 SAR` · "Priority" / "الأولوية" · "Payment" / "الدفع".
   - Progress tracker with 6 dots and labels "Draft" / "مسودة" · "Scheduled" / "مجدولة" · "Assigned" / "مُسندة" · "On way" / "في الطريق" · "Work" / "العمل" · "Done" / "تم": reached dots filled with ✓, current dot ringed.
   - Cancelled variant: banner "This visit was cancelled and is out of the workflow." / "تم إلغاء هذه الزيارة وهي خارج مراحل العمل." instead of the tracker.
2. **"Next Step" / "الخطوة التالية"** section (route icon)
   - Status icon + "Currently {0}" / "حاليًا {0}" + one-line hint for the role and status (see the hint table below).
   - Action buttons, full width:
     - forward moves filled in the target status color;
     - backward moves outlined;
     - *(admin, no technician, before dispatch)* filled "Assign technician" / "إسناد فني" on top.
   - Separate text button "Cancel visit" / "إلغاء الزيارة" in red.
   - Final state notice: "This visit has reached the end of its workflow." / "وصلت هذه الزيارة إلى نهاية مراحلها."
3. **"Client & Site" / "العميل والموقع"** section; header action "Change site" / "تغيير الموقع"
   - Avatar + client name, email, phone.
   - Action chips "Call" / "اتصال", "WhatsApp" / "واتساب" (green, with logo).
   - Site box: pin, city, address, chips "Map" / "الخريطة" and "Directions" / "الاتجاهات".
4. **"Schedule & Technician" / "الموعد والفني"** section; header action "Reschedule" / "إعادة جدولة"
   - Three stat tiles: "Date" / "التاريخ" · "Starts" / "يبدأ" · "Duration" / "المدة".
   - Flag line "Expected to finish around {0}" / "متوقع الانتهاء حوالي {0}".
   - Technician card: avatar, name, "{0} open jobs" / "{0} مهام مفتوحة", status pill, chips "Call" / "اتصال" · "Reassign" / "إعادة إسناد" · "Unassign" / "إلغاء الإسناد".
   - *(no technician)* inline empty "No technician assigned yet" / "لم يتم إسناد فني بعد" + chip "Assign technician" / "إسناد فني".
5. **"Service" / "الخدمة"** section; header action "Change" / "تغيير"
   - Name, category pill, price.
   - "Checklist · {0} tasks" / "قائمة المهام · {0} مهام" with a ✓ list, or "No checklist tasks" / "لا توجد مهام".
   - Pills: "Before photos required" / "صور ما قبل العمل مطلوبة" / "After photos required" / "صور ما بعد العمل مطلوبة" / "No photo proof required" / "لا يلزم إثبات بالصور".
6. **"Job Notes" / "ملاحظات العمل"** section; header action "Edit" / "تعديل"
   - Row "Priority" / "الأولوية" + pill.
   - Text blocks with a colored side bar: "Problem" / "المشكلة" and "Notes for the technician" / "ملاحظات للفني" (empty: "Nothing added yet" / "لم يُضف شيء بعد").
7. **"Proof Photos" / "صور الإثبات"** section *(if any photos exist or are required)*
   - One group per kind: "Before work (2)" + "Required" / "مطلوب" or "Done" / "تم" pill.
   - Thumbnail row, or "Not taken yet" / "لم تُلتقط بعد".
8. **"Invoice" / "الفاتورة"** section *(admin always; technician on own visit)*
   - Row: invoice number, pill "Issued {0}" / "صدرت {0}" or "Draft" / "مسودة", payment pill.
   - Balance card (gradient green → secondary): "Remaining balance" / "الرصيد المتبقي" or "Amount paid" / "المبلغ المدفوع", big amount, progress bar, "Paid {0}" / "المدفوع {0}" · "Total {0}" / "الإجمالي {0}".
   - *(if pending)* notice "{0} collected on site is awaiting admin confirmation" / "{0} محصّلة في الموقع بانتظار تأكيد المسؤول".
   - Due notice "Due by {0}" / "مستحقة بحلول {0}" or red "Overdue since {0}" / "متأخرة منذ {0}".
   - Technician: button "Collect payment" / "تحصيل الدفعة", or notice "The invoice is issued when the visit is completed. You can collect payment then." / "تصدر الفاتورة عند اكتمال الزيارة، ويمكنك تحصيل الدفعة حينها."
   - Admin: outlined green button "Open invoice" / "فتح الفاتورة" + caption "Issue, edit, payments and refunds are managed there." / "تُدار هناك عمليات الإصدار والتعديل والمدفوعات والاسترداد."
9. **"Activity" / "النشاط"** section; header action "Add note" / "إضافة ملاحظة"
   - Timeline, newest first, 5 shown, then "Show all ({0})" / "عرض الكل ({0})" / "Show less" / "عرض أقل".
   - Item: description; "05 Nov 2026 · 09:30 AM · Ahmed Saleh · Technician"; optional location chip "Technician location · {0} from site" / "موقع الفني · على بُعد {0} من الموقع"; optional quoted reason in italics.
   - Empty: "No activity yet" / "لا يوجد نشاط بعد".
10. *(admin, draft or cancelled, nothing invoiced)* Outlined red button "Delete visit" / "حذف الزيارة" with a trash icon.

**Next Step labels by status**

| Current | Admin buttons | Technician button |
|---|---|---|
| Draft | "Schedule visit" / "جدولة الزيارة" (+ "Assign technician" / "إسناد فني") | none, hint only |
| Scheduled | "Back to draft" / "العودة إلى مسودة" (+ "Assign technician" / "إسناد فني") | none |
| Assigned | "Start trip" / "بدء التنقل" | "Start trip" / "بدء التنقل" |
| On the way | "Start work" / "بدء العمل", "Back to assigned" / "العودة إلى مُسندة" | "Start work" / "بدء العمل" |
| In progress | "Complete visit" / "إكمال الزيارة" | "Complete visit" / "إكمال الزيارة" |
| Completed | none, end notice | none |
| Cancelled | "Reopen as draft" / "إعادة فتح كمسودة" | none |

Admin also has "Cancel visit" / "إلغاء الزيارة" in every state except Completed and Cancelled.

**Hints, admin:**
- "Complete the visit info, then schedule it." / "أكمل بيانات الزيارة ثم قم بجدولتها."
- "Assign a technician to dispatch this visit." / "أسند فنيًا لإرسال هذه الزيارة."
- "Waiting for the technician to start the trip." / "بانتظار بدء الفني للتنقل."
- "The technician is heading to the site." / "الفني في طريقه إلى الموقع."
- "Work is in progress at the site." / "العمل جارٍ في الموقع."
- "Visit done. The invoice is issued; confirm the collection or record the payment." / "اكتملت الزيارة وصدرت الفاتورة؛ أكّد التحصيل أو سجّل الدفعة."
- "This visit is cancelled. Reopen it to plan it again." / "هذه الزيارة ملغاة. أعد فتحها لتخطيطها من جديد."

**Hints, technician:**
- "The admin is still planning this visit." / "لا يزال المسؤول يخطط لهذه الزيارة."
- "Start the trip when you leave for the site." / "ابدأ الرحلة عند انطلاقك إلى الموقع."
- "Start work once you arrive. You must be within {0} of the site." / "ابدأ العمل عند وصولك. يجب أن تكون على بُعد {0} من الموقع أو أقل."
- "Finish the work, take the after photos and complete the visit." / "أنهِ العمل والتقط صور ما بعد العمل ثم أكمل الزيارة."
- "Well done. Collect the payment from the client if they pay now." / "أحسنت. حصّل الدفعة من العميل إذا كان سيدفع الآن."
- "The admin cancelled this visit." / "ألغى المسؤول هذه الزيارة."

**Which header actions show**
- "Change site" / "تغيير الموقع", "Reschedule" / "إعادة جدولة", "Reassign" / "إعادة إسناد" and photo switches: admin, before the technician leaves (draft, scheduled or assigned).
- "Unassign" / "إلغاء الإسناد": admin, assigned only.
- "Change" / "تغيير" service: admin, before dispatch, invoice untouched.
- "Edit" / "تعديل" notes: admin, until completed or cancelled.
- Technicians see **no** header edit actions; only "Add note" / "إضافة ملاحظة" on their own open visit.

**Frames to draw (minimum):**
1. Admin · Draft.
2. Admin · Scheduled, no technician.
3. Admin · Assigned.
4. Technician · Assigned.
5. Technician · In progress (photos, collect button).
6. Admin · Completed with a pending collection.
7. Admin · Cancelled.
8. Loading.
9. Error ("We could not load this visit" / "تعذّر تحميل هذه الزيارة" + "Try again" / "حاول مرة أخرى").

**Actions:** see the sheets below. "Map" / "الخريطة" / location chips → MAP-1. Thumbnails → MAP-3. "Directions" / "الاتجاهات" → Google Maps. "Open invoice" / "فتح الفاتورة" → INV-3.

#### COMP-3 · Field Proof Panel (component inside technician sheets)
Draw it as a component with states; it appears in VD-2, VD-9 and VD-10.

1. *(demo builds)* notice "Demo: your location is simulated at the site." / "تجربة: يُفترض أن موقعك داخل موقع العميل."
2. **Location card**
   - Header: target icon, "Your current location" / "موقعك الحالي", "Refresh" / "تحديث" or spinner.
   - Line "24.71360, 46.67530 · ±8 m · 09:31 AM".
   - Distance notice:
     - green "{0} from the site" / "على بُعد {0} من الموقع";
     - red "You are {0} from the site. Move within {1} to start work." / "أنت على بُعد {0} من الموقع. اقترب إلى {1} أو أقل لبدء العمل.";
     - grey "This site has no map location, so your current location is sent to the admin instead." / "لا يوجد لهذا الموقع إحداثيات على الخريطة، لذا يُرسل موقعك الحالي إلى المسؤول بدلًا منها."
   - Chip "View on map" / "عرض على الخريطة".
   - Checkbox "I confirm this is my current location and agree to share it with the admin." / "أؤكد أن هذا موقعي الحالي وأوافق على مشاركته مع المسؤول."
3. **Photo block** *(when the step takes photos)*
   - Camera icon, "{0} photos" / "صور {0}" (e.g. "Before work photos"), pill "Required" / "مطلوب" or "Optional" / "اختياري".
   - Thumbnail grid with ✕ on each.
   - Add tile "Add" / "إضافة" (hidden at 6 photos).

**States:**
- Locating ("Getting your location…" / "جارٍ تحديد موقعك…").
- Located and near.
- Too far.
- No site pin.
- Permission blocked: red notice "Location access is blocked. Allow it from the app settings." / "الوصول إلى الموقع محظور. اسمح به من إعدادات التطبيق." + chip "Open settings" / "فتح الإعدادات".
- GPS off: "Turn on location services to continue." / "شغّل خدمات الموقع للمتابعة."
- Mock location: "A mock location app is active. Turn it off to continue." / "تطبيق موقع وهمي مفعّل. أوقفه للمتابعة."
- Weak GPS: "Could not get your GPS location. Move to an open area and try again." / "تعذّر تحديد موقعك. انتقل إلى مكان مفتوح وحاول مرة أخرى."

#### VD-2 · Change Status (sheet)
- Title = action label (e.g. "Start work" / "بدء العمل"); subtitle = hint for the target status.
- Row: "from" pill → arrow → "to" pill.
- *(blocked)* red notice, e.g.:
  - "Assign a technician first." / "أسند فنيًا أولًا."
  - "Complete these first: {0}." / "أكمل هذه أولًا: {0}."
  - "The start time has already passed. Reschedule the visit first." / "لقد فات وقت البدء. أعد جدولة الزيارة أولًا."
  - "Refund all payments from the invoice before cancelling." / "استرد جميع مدفوعات الفاتورة قبل الإلغاء."
- *(cancel)* notice "The linked invoice will be marked as cancelled." / "سيتم تحديد الفاتورة المرتبطة كملغاة."
- *(reopen)* notice "The technician is released and the invoice becomes collectible again." / "يُحرر الفني وتصبح الفاتورة قابلة للتحصيل مرة أخرى."
- *(technician)* field proof panel; photo kind is before at Start work and after at Complete.
- *(cancel, reopen, or on the way → assigned)* field "Reason" / "السبب", placeholder "Why is this change needed?" / "لماذا هذا التغيير مطلوب؟", 8–500 characters.
- Button "Confirm" / "تأكيد". Disabled until proof is complete.

**Frames:** technician Start work (near + before photos); admin Cancel with reason; blocked.

#### VD-3 · Assign / Reassign Technician (sheet)
- Title "Assign technician" / "إسناد فني" / "Reassign technician" / "إعادة إسناد الفني".
- Subtitle "Technicians busy at this time are rejected automatically." / "يُستبعد تلقائيًا الفنيون المشغولون في هذا الوقت." or "Currently {0}" / "حاليًا {0}".
- *(draft)* notice "This draft is complete, so assigning a technician moves it straight to Assigned." / "هذه المسودة مكتملة، لذا سينقلها إسناد الفني مباشرة إلى مُسندة."
- Searchable dropdown "Technician" / "الفني" (search "Search for a technician" / "ابحث عن فني") + add link "Add New Technician" / "إضافة فني جديد".
- Selected technician card: avatar, name, status pill, "{0} open jobs" / "{0} مهام مفتوحة", star pill "Category match" / "تطابق الفئة".
- Gradient button "Assign" / "إسناد" (disabled until a choice is made).

#### VD-4 · Unassign Technician (sheet)
- Title "Unassign technician" / "إلغاء إسناد الفني", subtitle the technician's name.
- Notice "The visit goes back to Scheduled until another technician is assigned." / "تعود الزيارة إلى مجدولة حتى يُسند فني آخر."
- Field "Reason (optional)" / "السبب (اختياري)".
- Button "Unassign" / "إلغاء الإسناد".

#### VD-5 · Reschedule Visit (sheet)
- Title "Reschedule visit" / "إعادة جدولة الزيارة", subtitle "Currently {0}" / "حاليًا {0}".
- Pickers "Start date" / "تاريخ البدء" and "Start time" / "وقت البدء".
- *(technician set)* notice "We will check that {0} is free at the new time." / "سنتحقق من أن {0} متاح في الوقت الجديد."
- Field "Reason (optional)" / "السبب (اختياري)".
- Button "Save new time" / "حفظ الوقت الجديد".
- Errors: "Pick a date and a time" / "اختر التاريخ والوقت", "The new time must be in the future" / "يجب أن يكون الوقت الجديد في المستقبل".

#### VD-6 · Change Service (sheet)
- Title "Change service" / "تغيير الخدمة", subtitle "Current: {0}" / "الحالي: {0}".
- Searchable dropdown "Service" / "الخدمة".
- *(after choosing)* price change box "250.00 SAR ↗ 400.00 SAR", tiles "Duration" / "المدة" and "Tasks" / "المهام", notice "The draft invoice is repriced: discount and tax stay the same, the total follows the new price." / "يُعاد تسعير مسودة الفاتورة: يبقى الخصم والضريبة كما هما ويتغير الإجمالي حسب السعر الجديد."
- Button "Change service" / "تغيير الخدمة".

#### VD-7 · Change Site (sheet)
- Title "Change site" / "تغيير الموقع", subtitle "Current: {0}" / "الحالي: {0}".
- Dropdown "Site" / "الموقع" (red pin icon) + add link "Add new site" / "إضافة موقع جديد" (→ VIS-4).
- Notice "A draft invoice keeps a copy of the site, so it is updated too. Issued invoices are not changed." / "تحتفظ مسودة الفاتورة بنسخة من الموقع لذا تُحدّث أيضًا. لا تتغير الفواتير الصادرة."
- Button "Save site" / "حفظ الموقع".

#### VD-8 · Edit Job Notes (sheet)
- Title "Edit job notes" / "تعديل ملاحظات العمل".
- Dropdown "Priority" / "الأولوية" (each option in its color).
- Multiline "Problem" / "المشكلة" ("What does the client report?" / "ما المشكلة التي يذكرها العميل؟").
- Multiline "Notes for the technician" / "ملاحظات للفني" ("e.g., Gate code, call before arrival..." / "مثال: رمز البوابة، الاتصال قبل الوصول...").
- Switch rows "Require before-work photos" / "طلب صور ما قبل العمل" and "Require after-work photos" / "طلب صور ما بعد العمل", or a lock notice "Photo requirements are locked once the technician is on the way." / "تُقفل متطلبات الصور بمجرد أن يكون الفني في الطريق."
- Button "Save changes" / "حفظ التغييرات".

#### VD-9 · Add a Note (sheet)
- Title "Add a note" / "إضافة ملاحظة", subtitle "Notes are added to the visit activity log." / "تُضاف الملاحظات إلى سجل نشاط الزيارة."
- Multiline "Note" / "ملاحظة", placeholder "e.g., Client asked to call 30 minutes before arrival" / "مثال: طلب العميل الاتصال قبل الوصول بـ30 دقيقة", 3–500 characters.
- *(technician)* field proof panel with optional photos.
- Button "Add note" / "إضافة ملاحظة".

#### VD-10 · Collect Payment (sheet)
Technician.
- Title "Collect payment" / "تحصيل الدفعة", subtitle "The admin confirms the payment before it counts as paid." / "يؤكد المسؤول الدفعة قبل احتسابها مدفوعة."
- Field "Amount" / "المبلغ" (pre-filled with the full amount) + caption "Left to collect: {0}" / "المتبقي للتحصيل: {0}".
- Dropdown "Payment method" / "طريقة الدفع": "Cash" / "نقدًا" / "Card" / "بطاقة" / "Bank Transfer" / "تحويل بنكي" / "Mobile Wallet" / "محفظة إلكترونية" / "Other" / "أخرى".
- Field "Transaction reference" / "مرجع العملية", placeholder "Optional for cash" / "اختياري للدفع النقدي" or "Required" / "مطلوب".
- Field "Notes" / "ملاحظات" (required for Other).
- Field proof panel with **receipt** photos (at least 1 required).
- Button "Send to admin" / "إرسال إلى المسؤول".

#### VD-11 · Delete Visit (dialog)
- Warning icon, "Delete visit?" / "حذف الزيارة؟", "This permanently removes the visit and its draft invoice." / "سيؤدي هذا إلى حذف الزيارة ومسودة فاتورتها نهائيًا."
- Buttons "Cancel" / "إلغاء" and "Delete" / "حذف".

---

### Area D · Dispatch (admin)

#### DSP-1 · Dispatch Board
Full screen · admin. Draw a **phone** frame and a **1280 desktop** frame.

**Layout (phone)**
- Section app bar: ☰, hub icon, "Dispatch" / "التوزيع", right: tune icon ("Dispatch rules" / "قواعد التوزيع") → DSP-11.
- **Week strip**:
  - Row: ‹ (previous week), month + year with a dropdown arrow (opens a date picker), "Today" / "اليوم" (when another day is selected), › (next week).
  - 7 day cells: weekday, day number, small dot when the day has visits. Selected = gradient; today = tinted.
- **4 KPI tiles** (tappable, colored when above 0): "Unassigned" / "غير مسندة" · "Conflicts" / "التعارضات" · "Late" / "متأخرة" · "This day" / "هذا اليوم".
- **Pinned view switch** (segmented): "Technicians" / "الفنيون" · "Queue ({0})" / "قائمة الانتظار ({0})" · "Map" / "الخريطة".
- **Content**, by view:
  - Technicians: list of technician board cards.
  - Queue: DSP-3.
  - Map: DSP-4.
- **Docked tray** at the bottom (Technicians view only): DSP-5.

**Layout (desktop ≥ 900 px)**
- No Queue tab.
- Two columns: Queue (left, about 40%) | divider | technician board (right).

**States:**
- Loading.
- No technicians: "No technicians yet" / "لا يوجد فنيون بعد" / "Add technicians to start dispatching visits." / "أضف الفنيين لبدء توزيع الزيارات." / "Add technician" / "إضافة فني"
- Result toast "Visits assigned: {0}" / "الزيارات المسندة: {0}".

**Core gesture:** long-press a visit card, drag it onto a technician card, release, and DSP-6 opens. Design the **dragging state** too:
- the lifted card is slightly rotated and shadowed;
- the original card fades to 35%;
- the target card turns green (fits), amber (warning) or red (blocked).

#### DSP-2 · Technician Board Card
1. Header (tap to expand):
   - Avatar.
   - Name.
   - Pills: status (or "Day off" / "يوم إجازة"), "{0} visit{1}" / "{0} زيارات", up to 2 skills then "+N".
   - Chevron.
2. Workload line "{0} booked of {1}" / "{0} محجوزة من {1}" + percent (green under 75%, amber from 75%, red at 100%+), or "Not available on this day" / "غير متاح في هذا اليوم".
3. Timeline bar: one block per visit placed by time, with work start and end times at the ends.
4. *(while dragging over)* notice:
   - "Drop to assign at {0}" / "أفلت للإسناد في {0}";
   - "Drop to assign at {0} · {1}" / "أفلت للإسناد في {0} · {1}";
   - the blocking reason.
5. *(expanded)* that day's visit cards (or "No visits on this day" / "لا توجد زيارات في هذا اليوم"), then chips "Call" / "اتصال" · "Mark day off" / "تحديد يوم إجازة" / "Back to work" / "العودة للعمل" · "Redistribute" / "إعادة التوزيع".

**Variants:** collapsed; expanded; day off; drop-OK (green); drop-warning (amber); drop-blocked (red).

#### DSP-13 · Dispatch Visit Card
- Card with a colored left border (priority color).
- Row: visit number, ⚠ *(if conflict)*, status dot + status text.
- Service name ("No service" / "بدون خدمة").
- Client ("No client" / "بدون عميل").
- Clock + "09:30 AM · 1 h" (another day: full date in amber; none: "No time" / "بدون وقت").

**Variants:** normal; conflict; lifted (dragging); ghost (35%).

#### DSP-3 · Waiting Queue
- Row: search "Search waiting visits..." / "ابحث في الزيارات المنتظرة..." + text button "Select" / "تحديد" / "Done" / "تم".
- Rows: *(select mode)* checkbox + DSP-13 card, then underneath either a "Suggest technician" / "اقتراح فني" sparkle button or a grey reason ("Not ready to assign" / "غير جاهزة للإسناد" or what's missing).
- *(select mode, some selected)* sticky gradient button "Assign {0} visit{1}" / "إسناد {0} زيارة".
- **Empty:** "Every visit has a technician" / "كل زيارة لها فني" / "New visits without a technician will wait here." / "ستنتظر هنا الزيارات الجديدة التي ليس لها فني."
- **No match:** "No matching visits" / "لا توجد زيارات مطابقة" / "Try another search." / "جرّب بحثًا آخر."

#### DSP-4 · Map View
- Rounded map filling the area.
- Pins: waiting = amber with a person-off icon; assigned = status color with an engineer icon; white ring.
- Floating legend at top-left: "Waiting" / "بانتظار فني" · "Assigned" / "مُسندة".
- Attribution "OpenStreetMap contributors" / "مساهمو OpenStreetMap".
- **Empty:** "No visits on the map" / "لا توجد زيارات على الخريطة" / "Visits appear here when their site was picked on a map." / "تظهر الزيارات هنا عند تحديد موقعها على الخريطة."
- **Tap a pin:** DSP-7.

#### DSP-5 · Unassigned Tray (phone)
- Docked panel above the bottom edge.
- Handle row: count badge, "Waiting for a technician" / "بانتظار فني", hint "Long-press a card and drop it on a technician" / "اضغط مطولًا على البطاقة ثم أفلتها على فني" (or "All visits have a technician 🎉" / "كل الزيارات لها فني 🎉"), chevron.
- Expanded: horizontal scrolling row of DSP-13 cards.
- **Variants:** collapsed; expanded.

#### DSP-6 · Assign Visit (sheet)
- Title "Assign visit" / "إسناد الزيارة", subtitle "To {0}" / "إلى {0}".
- Route box: visit number + service → arrow → technician avatar + name.
- Two tappable tiles: "Date · tap to change" / "التاريخ · اضغط للتغيير" and time ("Until {0}" / "حتى {0}" as label).
- Rule results:
  - all OK: green notice "All dispatch rules are met." / "جميع قواعد التوزيع مستوفاة.";
  - otherwise a list of notices: blocks (red, block icon) above warnings (amber).
- *(warnings)* field "Reason to continue anyway" / "سبب المتابعة رغم ذلك" (required, 8+ characters).
- Button "Assign" / "إسناد" (gradient), or "Assign anyway" / "إسناد على أي حال" with warnings, or disabled when blocked.

**Rule messages to use in mockups:**
- "Outside working hours." / "خارج ساعات العمل."
- "{0} is busy with {1} ({2} – {3})." / "{0} مشغول في {1} ({2} – {3})."
- "{0} is off on this day." / "{0} في إجازة هذا اليوم."
- "Less than {0} min of travel time around {1}." / "وقت التنقل أقل من {0} دقيقة حول {1}."
- "{0} already has {1} visits on this day (limit {2})." / "لدى {0} بالفعل {1} زيارات في هذا اليوم (الحد {2})."
- "{0} has no "{1}" specialty." / "ليس لدى {0} تخصص "{1}"."
- "{0} is marked offline." / "{0} غير متصل."
- "The start time has already passed." / "لقد فات وقت البدء."

#### DSP-7 · Visit Quick Sheet
- Title "Visit" / "زيارة".
- Row: visit number + status pill.
- Icon lines: service · client · site · date-time · duration · technician (or "Waiting for a technician" / "بانتظار فني").
- "Priority" / "الأولوية" chips (tap saves immediately).
- Action chips: "Assign" / "إسناد" / "Reassign" / "إعادة إسناد" · "Unassign" / "إلغاء الإسناد" · "Reschedule" / "إعادة جدولة" · "Update status" / "تحديث الحالة" · "Full details" / "كل التفاصيل".

#### DSP-8 · Bulk Assign (sheet)
- Title "Assign {0} visits" / "إسناد {0} زيارات", subtitle "Review the plan, then confirm" / "راجع الخطة ثم أكّد".
- Row: "Plan for" / "خطة يوم" + date chip.
- Technician chips: "Best for each" / "الأنسب لكل زيارة" + one chip per technician.
- Plan rows (colored left border + icon):
  - green "Ahmed Saleh at 10:00 AM";
  - amber with a warning;
  - red "No technician is available." / "لا يوجد فني متاح."
- *(warnings)* notice "Some assignments break a warning rule. They will be saved with a note in the visit history." / "بعض الإسنادات تخالف قاعدة تنبيه. ستُحفظ مع ملاحظة في سجل الزيارة."
- Button "Assign {0} of {1}" / "إسناد {0} من {1}", or disabled "Nothing can be assigned" / "لا يمكن إسناد أي زيارة".

#### DSP-9 · Suggested Technicians (sheet)
- Title "Suggested technicians" / "الفنيون المقترحون", subtitle "Best match first: specialty, free time, distance and status" / "الأنسب أولًا: التخصص، الوقت المتاح، المسافة والحالة".
- Row: visit number · service + date chip.
- Ranked tiles: avatar, name, green "Free at {0}" / "متاح في {0}" or red reason, "Best match" / "الأنسب" pill on the first, chevron.
- Reason pills: "Specialty match" / "تطابق التخصص", "Free all day" / "متاح طوال اليوم", "{0} visit{1} that day" / "{0} زيارات في ذلك اليوم", "{0} km from another job" / "على بعد {0} كم من مهمة أخرى", "{0} warning{1}" / "{0} تنبيهات".
- Ineligible tiles are dimmed.
- **Empty:** "No other technicians to suggest" / "لا يوجد فنيون آخرون لاقتراحهم".
- **Tap a tile:** DSP-6.

#### DSP-10 · Redistribute Visits (sheet)
- Title "Redistribute visits" / "إعادة توزيع الزيارات", subtitle "From {0}" / "من {0}".
- Notice "Plan for {0}. Each visit goes to the best available colleague at the closest time." / "خطة يوم {0}. كل زيارة تذهب إلى أنسب زميل متاح في أقرب وقت."
- *(some started)* amber notice "{0} visit{1} already under way and stay{2} with {3}." / "{0} زيارات جارية بالفعل وتبقى مع {3}."
- Plan rows (as DSP-8).
- Button "Move {0} of {1}" / "نقل {0} من {1}", or "Nobody is available" / "لا يوجد أحد متاح".
- **Empty:** "No visits on this day can be moved" / "لا يمكن نقل أي زيارة في هذا اليوم".

#### DSP-11 · Dispatch Rules (sheet)
- Title "Dispatch rules" / "قواعد التوزيع", subtitle "Applied to every assignment on the board" / "تُطبّق على كل إسناد في لوحة التوزيع".
- "Working hours" / "ساعات العمل": two tappable tiles "Day starts" / "بداية الدوام" (08:00 AM) and "Day ends" / "نهاية الدوام" (06:00 PM).
- "Visits per technician per day" / "عدد زيارات الفني في اليوم": stepper − 6 +.
- "Travel time between visits" / "وقت التنقل بين الزيارات": chips "None" / "بدون" · 15 · 30 · 45 · 60 ("{0} min" / "{0} دقيقة").
- Switch row "Require matching specialty" / "اشتراط تطابق التخصص" / "Off: a mismatch is only a warning" / "عند الإيقاف: عدم التطابق مجرد تنبيه".
- Shield notice "Always enforced: no double booking, no visits on a day off, and visits must be complete before they are planned." / "مطبّق دائمًا: لا حجز مزدوج، ولا زيارات في يوم الإجازة، ويجب اكتمال الزيارة قبل جدولتها."
- Gradient button "Save rules" / "حفظ القواعد".

#### DSP-12 · KPI List (sheet)
- Title: "Waiting for a technician" / "بانتظار فني" / "Conflicts on this day" / "التعارضات في هذا اليوم" / "Late visits" / "الزيارات المتأخرة" / "Visits on this day" / "زيارات هذا اليوم".
- Stack of DSP-13 cards.
- **Empty:** "Nothing here right now" / "لا شيء هنا حاليًا".

#### DSP-14, DSP-15, DSP-16 · Board versions of Unassign, Reschedule, Status
Same purpose as VD-4, VD-5 and VD-2, opened from DSP-7.
- **DSP-14:** notice "{0} goes back to the queue and {1} is free at {2}." / "تعود {0} إلى قائمة الانتظار ويصبح {1} متاحًا في {2}."
- **DSP-15:** "Currently {0} with {1}" / "حاليًا {0} مع {1}"; live rule list as DSP-6; buttons "Save new time" / "حفظ الوقت الجديد" / "Move anyway" / "نقل على أي حال".
- **DSP-16:** title "Update status" / "تحديث الحالة", "Currently {0}" / "حاليًا {0}", one selectable row per allowed status (blocked rows at 55% opacity with the reason under the label), "Reason" / "السبب" when needed, "Confirm" / "تأكيد".

**Recommendation:** design one shared component for each pair (VD and DSP) so they look the same.

---

### Area E · Dashboard (admin)

#### DSH-1 · Dashboard
Full screen · admin. The default admin screen. Draw **phone** and **1280 desktop** frames.

**Layout**
1. Header (no standard app bar):
   - ☰;
   - greeting "Good morning" / "صباح الخير" / "Good afternoon" / "مساء الخير" / "Good evening" / "مساء الخير";
   - headline "Operations overview" / "نظرة عامة على العمليات";
   - small line "30 Oct – 05 Nov · vs previous 7 days · "updated {0}" / "آخر تحديث {0}"";
   - refresh icon.
2. Period chips: "Today" / "اليوم" · "7 days" / "7 أيام" (default) · "30 days" / "30 يومًا" · "This month" / "هذا الشهر" · "Custom…" / "مخصص…"
3. KPI grid (2 columns on phone, 4 on desktop):
   - "Visits" / "الزيارات" "31", caption "{0} due so far" / "{0} حان وقتها حتى الآن", delta ↑48%.
   - "Completion" / "نسبة الإنجاز" "100%", caption "{0} of {1} done" / "تم إنجاز {0} من {1}" (or "Nothing due yet" / "لا شيء حان وقته بعد"), delta in points "{0} pts" / "{0} نقطة".
   - "Collected" / "المحصّل" "5280 SAR", caption "{0} outstanding" / "{0} مستحق", delta ↓9%.
   - "Needs attention" / "يحتاج انتباهك" "43", caption "Items to handle now" / "مهام تحتاج معالجة الآن" / "All on track" / "كل شيء على المسار الصحيح"; red border when above 0.
4. **"Needs attention" / "يحتاج انتباهك"** panel: subtitle "{0} item{1} to handle" / "{0} مهام للمعالجة", action "Review" / "مراجعة". Rows with icon, title, hint and count:
   - "Late visits" / "الزيارات المتأخرة" / "Start passed, not started" / "فات الموعد ولم تبدأ";
   - "Waiting for a technician" / "بانتظار فني" / "Scheduled, nobody assigned" / "مجدولة، بدون فني";
   - "Ready to invoice" / "جاهزة للفوترة" / "Completed, invoice not issued" / "مكتملة، الفاتورة لم تصدر";
   - "Overdue invoices" / "الفواتير المتأخرة" / "Owed after due date" / "مستحقة بعد تاريخ الاستحقاق".
   - All clear: ✓ "No late visits, unassigned work or overdue invoices right now." / "لا توجد زيارات متأخرة أو أعمال غير مسندة أو فواتير متأخرة حاليًا."
5. **"Today's operations" / "عمليات اليوم"** panel: subtitle "{0} visit{1} today" / "{0} زيارات اليوم", action "All" / "الكل". Five stage tiles (icon, count, label): Scheduled · Assigned · On the way · In progress · Completed.
6. **"Visits trend" / "اتجاه الزيارات"** panel: subtitle "{0} · tap a bar to see those visits" / "{0} · اضغط على عمود لعرض الزيارات", action "Details" / "التفاصيل".
   - Readout row: "Tap a bar for details" / "اضغط على عمود لعرض التفاصيل" ··· "{0} visits" / "{0} زيارات".
   - Stacked bar chart (completed green under not-completed primary).
   - Legend "Completed" / "مكتملة" / "Not completed" / "غير مكتملة".
7. **"Technicians" / "الفنيون"** panel: subtitle "Completed visits in this period" / "الزيارات المكتملة في هذه الفترة", action "Compare" / "مقارنة". Up to 4 rows: avatar, name, progress bar, "5/7", "71%".
8. **"Go to" / "انتقل إلى"** grid of 7 shortcut tiles: "New visit" / "زيارة جديدة", "Dispatch" / "التوزيع", "Visits" / "الزيارات", "Clients" / "العملاء", "Technicians" / "الفنيون", "Services" / "الخدمات", "Invoices" / "الفواتير".

**Desktop:** KPI row of 4, then two columns: left (trend + technicians), right (attention + today + shortcuts).

**States:**
- First load (centered spinner).
- Error: "The dashboard could not load" / "تعذّر تحميل لوحة المعلومات" / "Your data is safe. Try again in a moment." / "بياناتك آمنة. حاول مرة أخرى بعد لحظات." / "Try again" / "حاول مرة أخرى"
- Empty company: "Your dashboard starts with a visit" / "لوحة معلوماتك تبدأ بزيارة" / "Create visits and assign technicians to see your operations, completion and revenue here." / "أنشئ الزيارات وأسند الفنيين لترى عملياتك ونسبة الإنجاز والإيرادات هنا." / "Create first visit" / "أنشئ أول زيارة" (+ shortcuts)
- Refreshing (dimmed).

**Actions:** KPI → DSH-2 in that mode. Bar → DSH-2 Visits filtered. Stage tile → DSH-2 Visits for today. Technician row → DSH-3.

#### DSH-2 · Insight (one screen, four modes)
- Pushed header with the mode title: "Visits" / "الزيارات" · "Completion" / "نسبة الإنجاز" · "Revenue" / "الإيرادات" · "Needs attention" / "يحتاج انتباهك".
- Breadcrumb: "Overview" / "نظرة عامة" › Visits (earlier parts tappable).
- Period chips (not in Attention mode).

**Modes**
- **Visits:**
  - 3 mini stats: "Visits" / "الزيارات" · "Cancelled" / "ملغاة" · "Per day" / "في اليوم".
  - "Visits over time" / "الزيارات عبر الوقت" chart ("Tap a bar to list that {0}" / "اضغط على عمود لعرض زيارات ذلك {0}").
  - "By status" / "حسب الحالة" bar list ("Tap a status to filter the list" / "اضغط على حالة لتصفية القائمة").
  - "By service category" / "حسب فئة الخدمة" bar list.
  - List titled "{0} visit{1}" / "{0} زيارات", subtitle "All in this period" / "كل ما في هذه الفترة" / "Filtered: {0}" / "مصفّاة: {0}", action "Clear filter" / "مسح التصفية".
- **Completion:**
  - Mini stats "Completion" / "نسبة الإنجاز" · "Completed" / "مكتملة" · "Not done yet" / "لم تُنجز بعد".
  - Info note "Completion = completed ÷ visits whose start time has passed. Cancelled visits are not counted." / "نسبة الإنجاز = المكتملة ÷ الزيارات التي حان وقتها. لا تُحتسب الزيارات الملغاة."
  - Chart "Completed vs not completed" / "المكتملة مقابل غير المكتملة".
  - "By technician" / "حسب الفني" bar list ("Tap a technician for their full results" / "اضغط على فني لعرض نتائجه الكاملة").
  - List with a segmented control "Not completed" / "غير مكتملة" | "Completed" / "مكتملة".
- **Revenue:**
  - Mini stats "Collected" / "المحصّل" · "Invoiced" / "المفوتر" · "Outstanding" / "المستحق".
  - Note "Collected = payments minus refunds, by payment date. Outstanding is what customers owe today on issued invoices." / "المحصّل = المدفوعات ناقص المبالغ المستردة حسب تاريخ الدفع. المستحق هو ما يدين به العملاء اليوم على الفواتير الصادرة."
  - Money chart "Money collected" / "المبالغ المحصلة".
  - "Payments" / "المدفوعات" list: arrow icon, "INV-000124 · Najd Bakery", date, "+250.00 SAR" (refund in red with "-").
  - "Overdue invoices" / "الفواتير المتأخرة" list.
- **Attention:** four sections, each a list:
  - "Late visits" / "الزيارات المتأخرة" (action "Open Dispatch" / "فتح التوزيع");
  - "Waiting for a technician" / "بانتظار فني" (action "Assign in Dispatch" / "الإسناد من التوزيع");
  - "Ready to invoice" / "جاهزة للفوترة";
  - "Overdue invoices" / "الفواتير المتأخرة".

**List rows:**
- Visit: "VIS-000124 · Najd Bakery", "05 Nov 2026 · 09:30 AM · Ahmed Saleh", status text, chevron.
- Invoice: "INV-000124 · Najd Bakery", "{0} · due {1}" / "{0} · مستحقة {1}", amount, chevron.

**Empty texts:** "No visits in this period" / "لا توجد زيارات في هذه الفترة", "No visits match this selection" / "لا توجد زيارات مطابقة لهذا الاختيار", "Everything due is completed" / "تم إنجاز كل ما حان وقته", "No payments in this period" / "لا توجد مدفوعات في هذه الفترة", "No overdue invoices" / "لا توجد فواتير متأخرة", "Nothing is late" / "لا توجد زيارات متأخرة", "Every scheduled visit has a technician" / "كل زيارة مجدولة لها فني", "All completed work is invoiced" / "تمت فوترة كل الأعمال المكتملة".

**Frames:** one per mode.

#### DSH-3 · Technician Results
- Pushed header with the technician's name.
- Breadcrumb.
- Period chips.
- Header card: avatar, name, status pill, "{0} active now" / "{0} نشطة الآن", text button "Profile" / "الملف الشخصي" (→ TEC-2).
- 4 mini stats: "Visits" / "الزيارات" · "Completed" / "مكتملة" · "Completion" / "نسبة الإنجاز" · "Collected" / "المحصّل".
- "Workload over time" / "عبء العمل عبر الوقت" chart.
- "By status" / "حسب الحالة" bar list.
- Visit list.
- **Missing state:** "This technician no longer exists" / "هذا الفني لم يعد موجودًا".

---

### Area F · Invoices and collections (admin)

#### INV-1 · Invoices List
- Section app bar: ☰, receipt icon, "Invoices" / "الفواتير".
- Search "Search invoice, visit number, client..." / "ابحث برقم الفاتورة أو الزيارة أو العميل..." + filter button.
- List of **Invoice cards** (pull to refresh). No add button: invoices are created with visits.

**Invoice card**
1. Row: receipt icon tile, invoice number (bold) over visit number (or "No visit number" / "بدون رقم زيارة"), status pill.
2. Person icon + client ("Customer not selected" / "لم يتم اختيار العميل").
3. Two amounts side by side: "Invoice total" / "إجمالي الفاتورة" and "Remaining" / "المتبقي" (green when 0).
4. Progress bar + "Paid {0}" / "المدفوع {0}".
5. Bottom row: calendar icon + "Due {0}" / "مستحقة {0}" (or "Created {0}" / "أُنشئت {0}" for drafts, or red ⚠ "Overdue · {0}" / "متأخرة · {0}"), then "Details" / "التفاصيل" ›.

Status pill texts: "Draft" / "مسودة", "Unpaid" / "غير مدفوعة", "Pending" / "قيد الانتظار", "Partially Paid" / "مدفوعة جزئيًا", "Paid" / "مدفوعة", "Cancelled" / "ملغاة", "Refunded" / "مستردة".

**States:**
- Loading.
- Empty: "No invoices yet" / "لا توجد فواتير بعد" / "An invoice is created automatically with every new visit." / "تُنشأ فاتورة تلقائيًا مع كل زيارة جديدة."
- No match: "No matching invoices" / "لا توجد فواتير مطابقة" / "Try another search or clear the filters." / "جرّب بحثًا آخر أو امسح التصفية." / "Clear search & filters" / "مسح البحث والتصفية"
- Card variants: draft, unpaid, partly paid, paid, overdue.

#### INV-2 · Filter Invoices (sheet)
- Title "Filter invoices" / "تصفية الفواتير", subtitle "Pick one or more options in each group" / "اختر خيارًا أو أكثر في كل مجموعة".
- Group "Stage" / "المرحلة": "Draft" / "مسودة", "Issued" / "صادرة", "Overdue" / "متأخرة".
- Group "Payment" / "الدفع": 6 chips.
- Buttons "Reset" / "إعادة ضبط" and "Apply" / "تطبيق".

#### INV-3 · Invoice Details
Full screen · admin. On desktop the content is limited to 680 px wide.

**Layout**
1. Pushed header "Invoice details" / "تفاصيل الفاتورة".
2. Row: invoice number (big) + payment status badge.
3. Gradient balance card: "Remaining balance" / "الرصيد المتبقي" / "Amount paid" / "المبلغ المدفوع" / "Refund completed" / "تم الاسترداد", big amount, progress bar, "Paid {0}" / "المدفوع {0}" · "Total {0}" / "الإجمالي {0}".
4. *(pending)* amber badge "{0} collected by the technician is awaiting your confirmation" / "{0} حصّلها الفني بانتظار تأكيدك".
5. *(overdue)* red badge "Overdue since {0}" / "متأخرة منذ {0}".
6. Panel "Customer & visit" / "العميل والزيارة": info lines "Customer" / "العميل", "Visit number" / "رقم الزيارة", "Location" / "الموقع", "Due date" / "تاريخ الاستحقاق".
7. Panel "Amount breakdown" / "تفاصيل المبلغ": "Subtotal" / "المجموع الفرعي", "Discount" / "الخصم" ("- 0.00 SAR"), "Tax" / "الضريبة", "Invoice total" / "إجمالي الفاتورة" (emphasized), "Paid" / "مدفوعة" (green), "Remaining" / "المتبقي" (emphasized).
8. *(if notes)* Panel "Notes" / "ملاحظات".
9. *(if payments)* Panel "Payments" / "المدفوعات" or "Payments ({0} awaiting confirmation)" / "المدفوعات ({0} بانتظار التأكيد)", containing payment tiles.
10. Buttons by state:
    - "Record payment" / "تسجيل دفعة" (filled, card icon);
    - "Issue invoice" / "إصدار الفاتورة" (filled);
    - one outlined button: "Edit draft" / "تعديل المسودة" (primary) for a draft, or "Refund payment" / "استرداد دفعة" (red) after payment.
11. *(no actions)* "No financial actions available for this invoice." / "لا توجد إجراءات مالية متاحة لهذه الفاتورة."
12. Footnote "Changes are saved locally on this device." / "تُحفظ التغييرات محليًا على هذا الجهاز."

**Frames:**
1. Draft (Edit draft + Issue invoice).
2. Issued unpaid (Record payment).
3. With a pending collection (tile with Confirm / Reject).
4. Paid (Refund).
5. Overdue.

**Payment tile (component)**
1. *(optional)* title "INV-000124 · VIS-000124 · Najd Bakery".
2. Row: amount (or red "Refund {0}" / "استرداد {0}") + entry status pill.
3. "Cash · 05 Nov 2026 · 09:30 AM · Ahmed Saleh".
4. *(optional)* "Reference: {0}" / "المرجع: {0}".
5. *(optional)* notes.
6. *(optional)* location chip "Where it was collected" / "مكان التحصيل".
7. *(optional)* receipt thumbnails row.
8. *(reviewed)* line "{0} by {1}" / "{0} بواسطة {1}" · date · note.
9. *(pending)* buttons: outlined red ✕ "Reject" / "رفض" + filled ✓ "Confirm" / "تأكيد".

**Variants:** pending (colored border); confirmed; rejected; refund.

#### INV-4 · Collections
- Section app bar: ☰, payments icon, "Collections" / "التحصيلات".
- Summary card (gradient amber → secondary): "Awaiting your confirmation" / "بانتظار تأكيدك", total amount, "{0} collections from technicians" / "{0} تحصيلات من الفنيين".
- Payment tiles (pending only), each with a title line.
- **Empty:** "Nothing to confirm" / "لا يوجد ما يحتاج إلى تأكيد" / "Payments technicians collect on site appear here until you confirm them." / "تظهر هنا المدفوعات التي يحصّلها الفنيون في الموقع حتى تؤكدها."

#### INV-5 · Record a Payment (sheet)
- Title "Record a payment" / "تسجيل دفعة", subtitle "Remaining balance: {0}" / "الرصيد المتبقي: {0}".
- Field "Amount" / "المبلغ" ("0.00").
- Dropdown "Payment method" / "طريقة الدفع".
- Field "Transaction reference" / "مرجع العملية" ("Optional for cash" / "اختياري للدفع النقدي" / "Required" / "مطلوب").
- Field "Notes" / "ملاحظات".
- Button "Save payment" / "حفظ الدفعة".
- **Errors:** "Enter a valid amount (up to 2 decimals)" / "أدخل مبلغًا صحيحًا (حتى منزلتين عشريتين)", "Amount must be above zero" / "يجب أن يكون المبلغ أكبر من صفر", "Maximum allowed: {0}" / "الحد الأقصى المسموح: {0}", "Reference is required" / "المرجع مطلوب", "Explain other payment method" / "وضّح طريقة الدفع الأخرى".

#### INV-6 · Edit Draft Invoice (sheet)
- Title "Edit draft invoice" / "تعديل مسودة الفاتورة", subtitle "Subtotal {0} · only before issue" / "المجموع الفرعي {0} · قبل الإصدار فقط".
- Field "Discount" / "الخصم".
- Field "Tax amount" / "مبلغ الضريبة".
- Field "Invoice notes" / "ملاحظات الفاتورة".
- Button "Save changes" / "حفظ التغييرات".

#### INV-7 · Refund Payment (sheet)
- Title "Refund payment" / "استرداد دفعة", subtitle "Refunds require a verified payment ledger." / "يتطلب الاسترداد سجل مدفوعات موثقًا."
- Field "Refund amount" / "مبلغ الاسترداد".
- Field "Reason" / "السبب" (8+ characters).
- Button "Confirm refund" / "تأكيد الاسترداد".

#### INV-8 · Issue Invoice (dialog)
- "Issue invoice?" / "إصدار الفاتورة؟" / "Total: {0}\nCheck the linked visit before confirming." / "الإجمالي: {0}\nتحقق من الزيارة المرتبطة قبل التأكيد."
- Buttons "Back" / "رجوع" and "Continue" / "متابعة".

#### INV-9 · Confirm Collection (dialog)
- "Confirm this collection?" / "تأكيد هذا التحصيل؟" / "{0} will be added to the paid amount of the invoice." / "ستتم إضافة {0} إلى المبلغ المدفوع في الفاتورة."
- Buttons "Back" / "رجوع" and "Confirm" / "تأكيد".

#### INV-10 · Reject Collection (dialog)
- "Reject this collection?" / "رفض هذا التحصيل؟" / "The amount stays unpaid on the invoice. Tell the technician why." / "يبقى المبلغ غير مدفوع في الفاتورة. وضّح للفني السبب."
- Multiline field, placeholder "Reason (at least {0} characters)" / "السبب ({0} أحرف على الأقل)".
- Buttons "Back" / "رجوع" and "Reject" / "رفض" (disabled until 8+ characters).

---

### Area G · Directory (admin)

#### CLI-1 · Clients List
- Section app bar "Clients" / "العملاء".
- Search "Search name, phone, email, city..." / "ابحث بالاسم أو الهاتف أو البريد أو المدينة..."
- List of **Client cards**.
- FAB "Add new client" / "إضافة عميل جديد".

**Client card**
- Colored left border.
- Initial avatar, name, city chip with a pin icon.
- Phone (green phone icon + WhatsApp logo when the number is on WhatsApp).
- Email.
- Two small stats: visits count with a cart icon, and total paid "SAR 1,250.00".
- Small buttons "Call" / "اتصال" and "WhatsApp" / "واتساب".
- Chevron.

**Empty:** "No clients yet" / "لا يوجد عملاء بعد" / "Add your first client to start booking visits." / "أضف أول عميل لتبدأ في حجز الزيارات." / "Add first client" / "أضف أول عميل"
**No match:** "No matching clients" / "لا يوجد عملاء مطابقون" / "Try a different name, phone or city." / "جرّب اسمًا أو هاتفًا أو مدينة مختلفة." / "Clear search" / "مسح البحث"

#### CLI-2 · Client Details
1. Pushed header "Client Details" / "تفاصيل العميل".
2. Curved colored header block:
   - big initial;
   - name;
   - address box with chips "Map" / "الخريطة" and "Directions" / "الاتجاهات";
   - phone row with call and WhatsApp buttons;
   - email row;
   - two stats: "Total Orders" / "إجمالي الطلبات" · "Total Paid" / "إجمالي المدفوع".
3. "Equipments" / "المعدات" section: title + small "+ Add" / "+ إضافة" button, then a horizontal row of equipment cards (gear avatar, name, delete icon, "Brand:" / "العلامة التجارية:" / "Model:" / "الطراز:" / "SN:" / "الرقم التسلسلي:" lines). Empty: "No equipments assigned to this client yet." / "لا توجد معدات مرتبطة بهذا العميل بعد."
4. Sticky title "Visit History" / "سجل الزيارات", then client-history visit cards:
   - left border in the status color;
   - visit number, date, service, amount, problem, technician;
   - status pill + payment pill.
   - Empty: "No visits recorded yet" / "لا توجد زيارات مسجلة بعد".
5. Fixed bottom bar: filled "Edit Client" / "تعديل العميل" + outlined red "Remove" / "حذف".

**Fallbacks:** "No Address" / "لا يوجد عنوان", "No Phone" / "لا يوجد هاتف", "No Email" / "لا يوجد بريد إلكتروني".

#### CLI-3 · Add / Edit Client
Pushed header "Add New Client" / "إضافة عميل جديد" / "Edit Client" / "تعديل العميل", then titled cards:
1. "Personal Info" / "البيانات الشخصية":
   - "Full Name *" / "الاسم الكامل *" ("e.g. Zeyad Khaled" / "مثال: زياد خالد");
   - "Email Address (Optional)" / "البريد الإلكتروني (اختياري)" ("client@example.com").
2. "Contact Info" / "بيانات التواصل":
   - phone field "Phone Number *" / "رقم الهاتف *" ("XXX XXXX XXXX");
   - WhatsApp toggle card "Number includes WhatsApp" / "الرقم مرتبط بواتساب" (logo, text, check circle; green when on).
3. "Location Details" / "تفاصيل الموقع":
   - dropdown "Select City *" / "اختر المدينة *";
   - "Address Configuration" / "إعداد العنوان";
   - map + address block.
4. "Extra Info" / "معلومات إضافية": multiline "Notes (Optional)" / "ملاحظات (اختياري)" ("Any special requests or details..." / "أي طلبات أو تفاصيل خاصة...").
5. Full-width button "Save Client" / "حفظ العميل" / "Update Client" / "تحديث العميل".

**Errors:** red outline on the field + toast, e.g. "Please fill in all fields marked with an asterisk (*)." / "يرجى تعبئة جميع الحقول المميزة بنجمة (*).", "Name must be at least 2 characters long" / "يجب ألا يقل الاسم عن حرفين", "Invalid phone number" / "رقم هاتف غير صحيح".

#### CLI-4 · Add New Equipment (dialog)
- Title "Add New Equipment" / "إضافة معدة جديدة".
- Fields "Equipment Name" / "اسم المعدة" (required: "Equipment name is required" / "اسم المعدة مطلوب"), "Brand" / "العلامة التجارية", "Model" / "الطراز", "Serial Number" / "الرقم التسلسلي".
- Buttons "Cancel" / "إلغاء" and "Save" / "حفظ".

#### TEC-1 · Technicians List
- Section app bar "Technicians" / "الفنيون".
- Search "Search name, phone, specialty..." / "ابحث بالاسم أو الهاتف أو التخصص..."
- **Technician cards**: initial avatar, name, status pill with a dot, skills line, phone (tap to call), "{0} Open Jobs" / "{0} مهام مفتوحة", chevron.
- FAB "Add new technician" / "إضافة فني جديد".
- **Empty:** "No technicians yet" / "لا يوجد فنيون بعد" / "Add technicians so you can assign them to visits." / "أضف الفنيين لتتمكن من إسنادهم إلى الزيارات." / "Add first technician" / "أضف أول فني"

#### TEC-2 · Technician Detail
1. Pushed header "Technician Detail" / "تفاصيل الفني".
2. Curved header: initial, name, status (uppercase), phone row + call button, email row, stats "Open Jobs" / "المهام المفتوحة" · "Completed" / "مكتملة" · "Total Paid" / "إجمالي المدفوع".
3. "Categories" / "الفئات" chips.
4. Sticky "Visit History" / "سجل الزيارات" + visit cards.
5. Bottom bar: "Edit Technician" / "تعديل الفني" + red "Remove" / "حذف".

#### TEC-3 · Add / Edit Technician
1. Pushed header "Add Technician" / "إضافة فني" (use a different title when editing).
2. Fields:
   - "Full Name *" / "الاسم الكامل *";
   - phone "Phone Number *" / "رقم الهاتف *";
   - "Email Address *" / "البريد الإلكتروني *" ("technician@example.com");
   - "Password *" / "كلمة المرور *" (hidden by default, eye toggle).
3. "Categories" / "الفئات": selectable chips (✓ when selected, at least one).
4. Button "Create Technician" / "إنشاء فني" / "Update Technician" / "تحديث الفني".
5. Password rule text for errors: "Your password is not strong enough. Use 8+ characters with uppercase, lowercase, number & symbol." / "كلمة المرور ضعيفة. استخدم 8 أحرف أو أكثر تتضمن حرفًا كبيرًا وصغيرًا ورقمًا ورمزًا."

#### SVC-1 · Services List
- Section app bar "Services" / "الخدمات".
- Search "Search service, category, task..." / "ابحث بالخدمة أو الفئة أو المهمة..."
- **Service cards**: service icon, name, category chip, edit icon, delete icon, price "SAR 250.00", checklist lines with small ✓.
- FAB "Add new service" / "إضافة خدمة جديدة".
- **Empty:** "No services yet" / "لا توجد خدمات بعد" / "Add the services you offer with their price and checklist." / "أضف الخدمات التي تقدمها مع أسعارها وقوائم مهامها." / "Add first service" / "أضف أول خدمة"
- **Design opportunity:** also show the duration on the card; it exists but isn't shown.

#### SVC-2 · Create / Update Service (tall bottom sheet)
1. Title "Create New Service" / "إنشاء خدمة جديدة" / "Update Service" / "تحديث الخدمة" + "Fill in the details below to add a service" / "أدخل التفاصيل أدناه لإضافة خدمة".
2. Dropdown "Category *" / "الفئة *"; its last item is "+ Create New Category" / "+ إنشاء فئة جديدة", which reveals the field "New Category Name *" / "اسم الفئة الجديدة *" ("e.g., HVAC" / "مثال: تكييف").
3. "Service Name *" / "اسم الخدمة *" ("e.g., Standard AC Tune-Up" / "مثال: صيانة مكيف قياسية").
4. Row: "Price *" / "السعر *" with "SAR" prefix + "Duration *" / "المدة *" with "Min" / "دقيقة" prefix.
5. "Service Checklist (Optional)" / "قائمة مهام الخدمة (اختياري)": field + "Add" / "إضافة" button, then removable chips.
6. Button "Save Service" / "حفظ الخدمة" / "Update Service" / "تحديث الخدمة".

---

### Area H · Shared full-screen tools

#### MAP-1 · Location View
- Full-screen map with a pin.
- Floating round back button (top-left).
- Recenter button ("Recenter map" / "إعادة توسيط الخريطة").
- Bottom card: "Location" / "الموقع" + address (or coordinates).

#### MAP-2 · Location Picker
- Full-screen map with a fixed center pin; the pin lifts while dragging.
- Top: round back button + search field "Search for a place..." / "ابحث عن مكان..." (spinner or clear ✕ inside).
- Suggestions card under the search: place icon, name, details. Or "No places found" / "لم يتم العثور على أماكن", or "Search unavailable. Check your connection." / "البحث غير متاح. تحقق من الاتصال."
- Bottom card: "Location" / "الموقع", address ("Locating..." / "جارٍ تحديد الموقع..." / "Fetching address..." / "جارٍ جلب العنوان..."), button "Confirm Location" / "تأكيد الموقع" (disabled while dragging).

#### MAP-3 · Photo Viewer
- Full-screen viewer, title "{0} of {1}" / "{0} من {1}".
- Swipe between photos, pinch to zoom.
- Caption at the bottom: "Before work · 05 Nov 2026 · 09:40 AM · Ahmed Saleh".
- Missing file: "This photo is no longer on this device" / "هذه الصورة لم تعد موجودة على هذا الجهاز".

#### Shared dialogs and toasts
- **Delete dialog** (used for clients, technicians, services and equipment):
  - "Remove Client?" / "حذف العميل؟" / "Are you sure you want to remove {0}? This action cannot be undone." / "هل أنت متأكد من حذف {0}؟ لا يمكن التراجع عن هذا الإجراء."
  - Buttons "Cancel" / "إلغاء" and "Delete" / "حذف".
- **Toasts:**
  - success: "Visit and invoice added successfully" / "تمت إضافة الزيارة والفاتورة بنجاح", "Technician assigned successfully" / "تم إسناد الفني بنجاح", "Visit rescheduled" / "تمت إعادة جدولة الزيارة", "Note added" / "تمت إضافة الملاحظة";
  - error: "This visit is not assigned to you." / "هذه الزيارة غير مسندة إليك.", "Wrong email or password." / "البريد الإلكتروني أو كلمة المرور غير صحيحة."
- **System pickers:** date, time and date range use the platform pickers recolored with `primary`.

---

## 6. Screen map

**Admin**
- Role Select → (Admin) → Dashboard [drawer: Dashboard · Dispatch · Visits · Invoices · Collections · Clients · Technicians · Services]
- Dashboard → Insight (4 modes) → Technician Results → Technician Detail
- Dashboard / Visits / Dispatch → Visit Details → sheets (Status, Assign, Unassign, Reschedule, Service, Site, Notes, Add note, Delete)
- Visit Details → Invoice Details → sheets (Record, Edit, Refund) and dialogs (Issue, Confirm, Reject)
- Visits → Add Visit → Site sheet / Add Client / Service sheet / Add Technician
- Dispatch → Quick sheet / Suggestions / Assign / Bulk / Redistribute / Rules / KPI lists
- Collections → Invoice Details, and Confirm / Reject dialogs
- Clients → Client Details → Edit Client / Add Equipment / Visit Details
- Technicians → Technician Detail → Edit Technician / Visit Details
- Services → Service sheet

**Technician**
- Role Select → Sign In → My Visits [drawer] → Visit Details → Status sheet, Add note, Collect payment (each with the field proof panel)
- Visit Details → Location View / Photo Viewer / Google Maps / phone / WhatsApp

## 7. Frame checklist

Phone frames are 390 × 844. "+ AR" means also draw it right-to-left in Arabic. "+ Dark" means also in dark mode.

| # | Page | Frame | Extra |
|---|---|---|---|
| 1 | Foundations | Colors (light + dark), type, spacing, radius, elevation | |
| 2 | Components | All components in section 3 with variants | |
| 3 | Auth | AUTH-2 Role Select | + AR, + Dark |
| 4 | Auth | AUTH-3 Sign In (empty, error, loading) | |
| 5 | Auth | AUTH-4 Log out dialog | |
| 6 | Admin shell | ADM-1 Drawer open over the Dashboard | + AR |
| 7 | Technician | TECH-1 My Visits (with current job; empty) | + AR, + Dark |
| 8 | Technician | TECH-2 Drawer | |
| 9 | Visits | VIS-1 list, empty, no match | + Dark |
| 10 | Visits | VIS-2 Filter sheet | |
| 11 | Visits | VIS-3 Add Visit (empty, filled, with technician, errors) | + AR |
| 12 | Visits | VIS-4 Site sheet | |
| 13 | Visit details | VD-1 × 9 states listed in its section | + AR (one), + Dark (one) |
| 14 | Visit details | COMP-3 Field proof panel × all states | |
| 15 | Visit details | VD-2 Status sheet (technician Start work; admin Cancel; blocked) | |
| 16 | Visit details | VD-3 to VD-10 sheets, VD-11 dialog | |
| 17 | Dispatch | DSP-1 phone (Technicians view, tray expanded) | + AR |
| 18 | Dispatch | DSP-1 phone Queue view and Map view | |
| 19 | Dispatch | DSP-1 desktop 1280 | |
| 20 | Dispatch | Dragging state (lifted card, green / amber / red targets) | |
| 21 | Dispatch | DSP-6, DSP-7, DSP-8, DSP-9, DSP-10, DSP-11, DSP-12 sheets | |
| 22 | Dispatch | DSP-14, DSP-15, DSP-16 (or a note that they reuse VD components) | |
| 23 | Dashboard | DSH-1 phone (data; empty; error) | + AR, + Dark |
| 24 | Dashboard | DSH-1 desktop 1280 | |
| 25 | Dashboard | DSH-2 × 4 modes | |
| 26 | Dashboard | DSH-3 | |
| 27 | Invoices | INV-1 list (card variants), INV-2 | |
| 28 | Invoices | INV-3 × 5 states | + AR |
| 29 | Invoices | INV-4 Collections (with items; empty) | |
| 30 | Invoices | INV-5 to INV-7 sheets, INV-8 to INV-10 dialogs | |
| 31 | Directory | CLI-1, CLI-2, CLI-3, CLI-4 | |
| 32 | Directory | TEC-1, TEC-2, TEC-3 | |
| 33 | Directory | SVC-1, SVC-2 | |
| 34 | Shared | MAP-1, MAP-2 (with suggestions), MAP-3 | |
| 35 | Shared | Delete dialog, success toast, error toast | |

## 8. Prototype flows

1. **Admin creates and assigns a visit:**
   1. Dashboard → "New visit" / "زيارة جديدة" → Add Visit (choose client, site, service, technician, date, time).
   2. "Assigned" / "مُسندة" → toast → Visits list.
   3. → Visit Details (Assigned).
2. **Technician does the visit:**
   1. Sign In → My Visits → Visit Details (Assigned).
   2. "Start trip" / "بدء التنقل" → sheet (location + consent) → On the way.
   3. "Start work" / "بدء العمل" → sheet (near site + before photos) → In progress.
   4. "Complete visit" / "إكمال الزيارة" → sheet (after photos) → Completed.
   5. "Collect payment" / "تحصيل الدفعة" → sheet (receipt photo) → "Send to admin" / "إرسال إلى المسؤول".
3. **Admin confirms the payment:**
   1. Drawer → "Collections" / "التحصيلات" → "Confirm" / "تأكيد" → dialog → "Confirm" / "تأكيد".
   2. Open the invoice → Paid.
4. **Admin dispatches the day:**
   1. Dispatch → drag a waiting card onto a technician → Assign sheet → "Assign" / "إسناد".
   2. Then "Suggest technician" / "اقتراح فني" → pick the best match → "Assign" / "إسناد".

## 9. Rules your design must respect

**Visit rules**
- A technician can act only on **their own** visits and only forward: Start trip → Start work → Complete.
- Every technician action needs a fresh live location (under 3 minutes old) plus a consent tick. The location cannot be typed.
- "Start work" / "بدء العمل" needs the technician within **200 m** of the site when the site has a map pin.
- Photos come from the camera only, up to 6 per action. Before and after photos are required only if the visit says so.
- Photo requirements lock once the technician is on the way.
- Cancelling, reopening a cancelled visit, or moving on the way → assigned needs a reason of 8–500 characters.
- A visit can be deleted only while draft or cancelled, with no issued invoice and no payment.

**Money rules**
- Every visit has exactly one invoice.
- The invoice issues automatically when the visit completes; it is due 14 days later.
- The price comes from the service. Invoices allow only discount, a typed tax amount and notes, and only while a draft.
- A technician's collection is **pending** until the admin confirms it; it does not count as paid before that.
- Money has 2 decimals. Currency is SAR.

**Dispatch rules**

| Rule | Default |
|---|---|
| Working hours | 08:00–18:00 |
| Visits per technician per day | 6 |
| Travel buffer | 30 min |
| Specialty match | Warning only |

Double booking and days off always block.

**Not in the product** (do not design as if they exist):
- push notifications;
- live technician tracking;
- PDF or shared invoices;
- VAT rate;
- admin login;
- user or plan limits;
- offline mode;
- ticking checklist tasks.

If you want to propose any of these, put them on a separate "Ideas" page.

