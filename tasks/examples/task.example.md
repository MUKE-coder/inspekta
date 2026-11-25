# Inspekta task — Bright Schools Portal
<!-- Usually written by your project's AI into <app>/.inspekta/task.md (see README).
     Or copy to tasks/<app>.md (gitignored) and run:  /new-task tasks/<app>.md -->

## 1. Basics
- **App name:** Bright Schools Portal
- **App directory:** /Users/me/code/bright-schools
- **Framework / stack:** Grit v3 triple (Go/Gin/GORM API, Next.js web, admin panel)
- **Scope:** both
- **Other surfaces:** API https://api.brightschools-demo.com · Swagger /docs

## 2. Browser
- **Default browser:** chrome:Work        <!-- see README "Choosing the browser" -->
- **Signed-in Google accounts in that browser:** head.demo@gmail.com, teacher.demo@gmail.com

## 3. Login sites
| ID | Site | Sign-in URL | Auth methods |
|----|------|-------------|--------------|
| L1 | Admin panel | https://admin.brightschools-demo.com/login | password |
| L2 | School portal (staff) | https://app.brightschools-demo.com/staff/login | google, password |
| L3 | Parent portal | https://app.brightschools-demo.com/parents | otp (email, read from Mailhog https://mail.brightschools-demo.com) |

## 4. Roles & accounts
| Role | Login site | Auth method | Email / username | Password | Browser | What this role can do |
|------|-----------|-------------|------------------|----------|---------|-----------------------|
| super admin | L1 | password | admin@brightschools-demo.com | <demo password> | default | Manage schools, users, billing |
| headteacher | L2 | google | head.demo@gmail.com | — (Google, already signed in) | default | Manage one school's staff, classes, reports |
| teacher | L2 | password | teacher1@brightschools-demo.com | <demo password> | edge | Own classes, attendance, marks |
| parent | L3 | otp | parent1@brightschools-demo.com | — (OTP code) | cdp:9222 | View own child's results and fees |

- **Role test order:** super admin → headteacher → teacher → parent
- **2FA / CAPTCHA:** none on demo
- **Sign-up:** parents can self-register; Inspekta may create ONE test parent prefixed INSPEKTA-TEST

## 5. OAuth / Google sign-in
- Use the Google account already signed in to the browser; pick it from the account chooser.
- **Consent screen allowed?** yes, the app only asks for email + profile
- Never type a Google password. If Google asks for one, stop and ask me.

## 6. Feature map
| Area | Path | Roles | Key actions |
|------|------|-------|-------------|
| Schools | /admin/schools | super admin | create, edit, suspend |
| Staff | /staff | headteacher | invite, assign classes |
| Attendance | /attendance | teacher, headteacher | mark, edit, export CSV |
| Results | /results | teacher (edit), parent (view own) | enter marks, publish, view |

## 7. Test data
- Safe existing records: school "Demo Primary", class "P5 Blue"
- May create: records prefixed "INSPEKTA-TEST"
- Upload samples: /Users/me/code/bright-schools/testdata/students.csv

## 8. Constraints
- Don't delete seed records; don't send real emails (Mailhog only); don't touch billing

## 9. Known issues / recent changes
- Known: CSV export ignores date filter (#142)
- Changed recently: results publishing flow

## 10. Checklist
### Auth (every role)
- [ ] (each role) Log in on its own login site with its auth method → lands on the right dashboard
- [ ] (each role) Logout → protected pages redirect to that role's login site
- [ ] (headteacher) "Continue with Google" picks head.demo@gmail.com and signs in
- [ ] (parent) OTP code arrives in Mailhog and works; expired/wrong code shows a clear error
### Permissions
- [ ] (teacher) Cannot open /staff or /admin via menu OR direct URL
- [ ] (parent) Can only see own child's results
- [ ] (super admin) Cannot log in on the parent portal with admin credentials (if separated)
### Features
- [ ] (teacher) Mark attendance for P5 Blue → saved, success toast
- [ ] (teacher) Enter marks and publish → parent sees them
### UI
- [ ] Colours and theme (light/dark), loading states, empty states, mobile layout

## 11. Code review focus
- Dirs: apps/api, apps/web, apps/admin
- Commands: `go vet ./...` · `pnpm -r lint` · `pnpm -r typecheck` · `go test ./...`
- Risky: role middleware in apps/api/internal/middleware/auth.go
