class User < ActiveRecord::Base
  has_secure_password

  # すべてを網羅したものではない
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save { email.downcase! }

  # 存在性、長さ、フォーマット、一意性の検証
  #
  # NOTE: validates :uniqueness しても一意性は保証されないらしい！
  # 対策
  # - migration で add_index を用いて email にインデックスをはり、
  #   unique: true を指定してデータベースレベルでも一意性を強制させる。
  # - 加えて、email を保存する前に (コールバックを使おう) 小文字に変換しておく
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true,
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
end
