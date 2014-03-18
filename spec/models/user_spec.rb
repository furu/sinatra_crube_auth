require 'spec_helper'

describe User do

  before do
    @user = User.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar'
    )
  end

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
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  context 'when name is not present' do
    before { @user.name = '' }
    it { should_not be_valid }
  end

  context 'when email is not present' do
    before { @user.email = '' }
    it { should_not be_valid }
  end

  context 'when password is not present' do
    before do
      @user = User.new(
        name: 'Example User',
        email: 'user@example.com',
        password: ' ',
        password_confirmation: ' '
      )
    end
    it { should_not be_valid }
  end

  context "when password doesn't match confimation" do
    before { @user.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  describe 'return value of authenticate method' do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    context 'with valid password ' do
      it { should eq found_user.authenticate(@user.password) }
    end

    context 'with invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end

    after { User.destroy_all }
  end

  context "with a password that's too short" do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
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

    after do
      User.destroy_all
    end
  end

end
