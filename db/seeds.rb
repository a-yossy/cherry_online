Admin.create!(
  email: ENV['ADMIN_EMAIL'],
  password: ENV['ADMIN_PASSWORD']
)

50.times do |i|
  Author.create!(name: "author#{i + 1}")
end

50.times do |i|
  web_book = WebBook.new(
    title: "title#{i + 1}",
    release_date: Date.current + 2 - i,
    price: 1000 + (100 * i),
    description:
      "# 説明#{i + 1}\n## 説明#{i + 1}\n***\n```ruby\ndef sum(a, b)\n\s\sa + b\nend\n```",
    released: false
  )
  web_book.cover_image.attach(io: File.open(Rails.root.join('./public/images/no_image.png')), filename: 'no_image.png')
  web_book.save!

  5.times do |j|
    Page.create!(
      title: "ページタイトル#{i + 1}#{j + 1}",
      body: "# 本文#{i + 1}#{j + 1}\n## 本文#{i + 1}#{j + 1}\n***\n```ruby\ndef sum(a, b)\n\s\sa + b\nend\n```",
      web_book: web_book,
      page_order: j
    )
  end

  web_book.update(released: true)
end

50.times do |i|
  WebBookAuthor.create!(author_id: i + 1, web_book_id: i + 1)
  WebBookAuthor.create!(author_id: 50 - i, web_book_id: i + 1)
end

not_released_web_book = WebBook.new(
  title: 'title',
  release_date: Date.current,
  price: 1000,
  description:
    "# 説明\n## 説明\n***\n```ruby\ndef sum(a, b)\n\s\sa + b\nend\n```",
  released: false
)
not_released_web_book.cover_image.attach(io: File.open(Rails.root.join('./public/images/no_image.png')), filename: 'no_image.png')
not_released_web_book.save!

WebBookAuthor.create!(author_id: 1, web_book: not_released_web_book)
