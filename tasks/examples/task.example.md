# Example task file
<!-- Copy to tasks/<app>.md (gitignored) and run:  /new-task tasks/<app>.md
     Or just type NEW TASK in a session and paste these details. -->

- **App name:** Acme CRM
- **App directory:** /Users/me/code/acme-crm
- **Live URL:** https://crm.acme-demo.com
- **Sign-in URL:** https://crm.acme-demo.com/login
- **Scope:** both
- **Credentials:**
  - admin: admin@acme-demo.com / <demo password>
  - user: sales@acme-demo.com / <demo password>
- **Constraints:** don't delete existing seed records; don't send real emails
- **Focus areas:** onboarding, clients list, invoices

## Checklist
- [ ] Login and logout for both roles
- [ ] Dashboard loads with correct stats
- [ ] Create, edit, delete a client (use a new test client only)
- [ ] Search and filter clients
- [ ] Check colours and theme (light/dark)
- [ ] Check loading states on lists
- [ ] Check empty states (search with no results)
- [ ] Create an invoice and download PDF
- [ ] Sales user cannot access admin settings
