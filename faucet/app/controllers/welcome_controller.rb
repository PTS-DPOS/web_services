class WelcomeController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:widget]

  def index
    write_referral_cookie(params[:r]) if params[:r]

    if params[:account_name] and params[:account_key]
      @account_name = params[:account_name]
      session[:pending_registration] = {account_name: params[:account_name], account_key: params[:account_key]}
      redirect_to bitshares_account_path if user_signed_in?
    else
      @account = PtsAccount.new(name: '', key: '')
    end

    @asset = Asset.where(assetid: 0).first
    @faucet_account = Rails.application.config.bitshares.pts_faucet_account
    @faucet_balance = Rails.cache.fetch('key', expires_in: 1.minute) do
      begin
        res = BitShares::API::Wallet.account_balance(@faucet_account)
        res[0][1][0][1]/@asset.precision
      rescue
        0
      end
    end
  end

  def account_registration_step2
    @account = PtsAccount.new(pts_account_params)
    logger.debug "PtsAccount:"
    logger.debug "#{@account}; #{@account.valid?}; #{@account.errors}"
    @account_name = @account.name
    session[:pending_registration] = {account_name: @account.name, account_key: @account.key}
    redirect_to bitshares_account_path if user_signed_in?
  end

  def test_widget
  end

  def refscoreboard
    if request.xhr?
      @refs = PtsAccount.filter(params[:scope]).grouped_by_referrers
      render '_refs', layout: false
    else
      @refs = PtsAccount.grouped_by_referrers
    end
  end

  def bitshares_login
    client_key = params[:client_key]
    server_key = params[:server_key]
    signed_secret = params[:signed_secret]

    rpc_instance = BitShares::API.rpc

    login = rpc_instance.request('wallet_login_finish', [server_key, client_key, signed_secret])
    unless login
      flash[:alert] = 'Sorry, we cannot log you in. Your login session may have expired.'
      return
    end

    blockchain_account = rpc_instance.request('blockchain_get_account', [login['user_account_key']])
    account_name = blockchain_account['name']
    account_key = blockchain_account['owner_key']

    user = current_user

    pts_account = PtsAccount.where(key: account_key).first

    if user and pts_account and user.id != pts_account.user_id
      pts_account.update_attribute(:user_id, user.id)
      pts_account.user = user
    end

    if !user and pts_account
      user = pts_account.user
    end

    unless user
      user = User.create(
          name: account_name,
          email: "#{User::TEMP_EMAIL_PREFIX}-bitshares.com",
          password: Devise.friendly_token[0, 20],
          uid: @uid
      )
    end

    unless pts_account
      PtsAccount.create(name: account_name, key: account_key, user_id: user.id)
    end

    Identity.where(uid: account_key, provider: 'bitshares', user_id: user.id).first_or_create do |i|
      i.uid = account_key
      i.provider = 'bitshares'
      i.user_id = user.id
    end

    sign_in_and_redirect user, :event => :authentication
  end

  private

  def pts_account_params
    params.require(:account).permit(:name, :key)
  end

end
