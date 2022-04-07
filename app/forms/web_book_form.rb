class WebBookForm
  FORM_COUNT = 5
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :release_date, :date
  attribute :price, :integer
  attribute :description, :string
  attribute :released, :boolean
  attribute :cover_image
  attr_accessor :web_book, :authors

  # 作成・更新に応じてフォームのアクションを切り替えるため記述
  delegate :persisted?, to: :web_book

  def initialize(attributes = nil, web_book: WebBook.new)
    self.web_book = web_book
    attributes ||= web_book_default_attributes
    super(attributes)
    # 著者の入力欄がFORM_COUNT個生成されるよう実装
    self.authors = self.web_book.authors + (FORM_COUNT - self.web_book.authors.count).times.map { Author.new } if self.authors.blank?
  end

  def authors_attributes=(attributes)
    self.authors = attributes.map { |_, v| Author.find_or_initialize_by(v) }
  end

  def save
    return false unless authors_exist?

    execute
  end

  def releasable?
    !self.web_book.pages.size.zero?
  end

  private

  def execute
    ActiveRecord::Base.transaction do
      # 画像が新たに添付された場合のみ表紙画像の変更を行うよう実装
      if !cover_image && self.web_book.cover_image
        self.web_book.update!(title: title, release_date: release_date, price: price, description: description, released: released)
      else
        self.web_book.cover_image.purge
        self.web_book.update!(title: title, release_date: release_date, price: price, description: description, released: released, cover_image: cover_image)
      end

      WebBookAuthor.where(web_book: web_book).each(&:destroy!)
      self.authors.select { |author| author.name.present? }.each do |author|
        # 登録されていない同名の著者を複数入力した際に発生するエラーを回避
        author.save!
        WebBookAuthor.create!(web_book: web_book, author: author)
      end
    end
    true
  rescue => e
    errors.add(:base, e.message.split(','))
    false
  end

  def authors_exist?
    return true unless authors.count { |author| author.name.present? }.zero?

    raise Exceptions::WebBookFormError, '著者を入力してください'
  rescue => e
    errors.add(:base, e.message.split(','))
    false
  end

  def web_book_default_attributes
    {
      title: web_book.title,
      release_date: web_book.release_date,
      price: web_book.price,
      description: web_book.description,
      released: web_book.released,
    }
  end
end
