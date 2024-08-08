class ReportsController < ApplicationController

  has_scope :by_payment_status
  has_scope :by_user
  has_scope :by_product


  def index
    @all_users = User.active.includes(orders: :product)
    @all_products = Product.all
    @filtered_orders = apply_scopes(Order).includes(:user, :product)

    if params[:user_id].present?
      @filtered_orders = @filtered_orders.where(user_id: params[:user_id])
    end

    if params[:product_id].present?
      @filtered_orders = @filtered_orders.where(product_id: params[:product_id])
    end

    if params[:payment_status].present?
      @filtered_orders = @filtered_orders.where(state: params[:payment_status])
    end

    @filtered_users = @all_users.joins(:orders).where(orders: { id: @filtered_orders.pluck(:id) }).distinct
    @selected_user_id = params[:user_id]
    @selected_product_id = params[:product_id]

    params[:user_id] = nil
    params[:product_id] = nil
  end
  def user_reports
    @users = User.active.includes(orders: :product)
  end

  def user_report
    @user = User.find(params[:id])
    @users = User.active.includes(orders: :product)
    render :user_reports
  end

  def pay_all_orders
    user = User.find(params[:id])
    unpaid_orders = user.orders.unpaid

    if unpaid_orders.exists?
      unpaid_orders.each do |order|
        Payment.create(order: order, amount: order.product.price, state: 1)
        order.update(state: 'paid')
      end
      user.update(deposit: 0)
      notice_message = 'Все заказы успешно оплачены, депозит обнулен'
    else
      notice_message = 'Все заказы уже оплачены, изменений не внесено'
    end

    redirect_to user_reports_reports_path, notice: notice_message
  end

  def edit_payment
    @user = User.find(params[:id])
    total_unpaid_amount = @user.orders.unpaid.sum { |order| order.product.price }
    @current_debt = [total_unpaid_amount - @user.deposit, 0].max
  end

  def update_payments
    @user = User.find(params[:id])
    amount = params[:amount].to_f

    if amount.positive?
      @user.update(deposit: @user.deposit + amount)
      process_deposit(@user)
      notice_message = 'Все заказы успешно обновлены'
    else
      notice_message = 'Недопустимое значение'
    end

    redirect_to user_report_report_path(@user), notice: notice_message
  end

  private

  def process_deposit(user)
    remaining_amount = user.deposit
    user.orders.unpaid.order(:created_at).each do |order|
      if remaining_amount >= order.product.price
        Payment.create(order: order, amount: order.product.price, state: 1)
        order.update(state: 'paid')
        remaining_amount -= order.product.price
      end
    end
    user.update(deposit: remaining_amount)
  end
end
