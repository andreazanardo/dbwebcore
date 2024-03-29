# viene creata una sezione principale di default
section = Section.create(titolo: 'Principale', descrizione: 'Sezione principale del sito.', principale: true, percorso: '')

# viene creata una home page di default per la sezione principale
page = Page.create(titolo: 'Home page', section_id: section.id, home: true, slug: 'home-page', visibile: true)

row = Row.create(ordine: 1, page_id: page.id, estesa: false, colore_sfondo: '#ffffff')

Column.create(ordine: 1, contenuto: "<a href='/login'>Accedi</a> con utente <b>admin@dbweb.core</b> e password <b>123456</b> per poter amministrare il sito.".html_safe, row_id: row.id, larghezza: 12)

# viene creato un amministratore di default
user = User.new(email: 'admin@dbweb.core', password: '123456', password_confirmation: '123456', admin: true)
user.skip_confirmation!
user.save!