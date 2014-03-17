require 'spec_helper'

describe User do

  before { @user = User.new(name: 'Example User', email: 'user@example.com') }

  subject { @user }

  # before ブロック内では、ただ属性のハッシュを new に渡せるかどうか
  # をテストしているだけなので、次のようなテストを追加することで
  # user.name や user.email が正しく動作することを保証できるらしい。
  #
  # モデルの属性についてテストをすることで、
  # そのモデルが応答すべきメソッドの一覧が一目で分かるため、
  # モデルの属性をテストすることは良い習慣らしい。
  it { should respond_to(:name) }
  it { should respond_to(:email) }

  it { should be_valid }

  context 'when name is not present' do
    before { @user.name = '' }
    it { should_not be_valid }
  end

  context 'when email is not present' do
    before { @user.email = '' }
    it { should_not be_valid }
  end

  context 'when name is too long' do
    before { @user.name = 'a' * 51 }
    it { should_not be_valid }
  end

  context 'when email format is invalid' do
    it 'should be invalid' do
      address = %w[
        user@foo,com user_at_foo.org example.user@foo.foo.
        foo@bar_baz.com foo@bar+baz.com
      ]
      address.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  context 'when email format is valid' do
    it 'should be valid' do
      address = %w[
        user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn
      ]
      address.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  # 一意性のテストのためには、実際にレコードをデータベースに登録する必要がある
  context 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

end
