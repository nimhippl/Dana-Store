require 'telegram/bot'

class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create_order]

  def index
    @orders = Order.includes(:user, :product).where(deleted_at: nil)
  end

  def new
    @order = Order.new
    @products = Product.all
    @users = User.active
  end

  def create
    @order = Order.new(order_params)
    @order.state = 'unpaid'
    @order.cancelable_until = 24.hours.from_now

    if @order.save
      @order.product.decrement_quantity!(1)
      total_due = calculate_total_due(@order.user)
      message = "✅ Заказ оформлен!\n🚚Заказ: #{@order.product.name} - #{@order.product.price} ₽\n💳💵Итого долг: #{total_due} ₽"
      send_telegram_message(@order.user.telegram_chat_id, message)
      redirect_to orders_path, notice: 'Заказ успешно создан'
    else
      @products = Product.all
      @users = User.active
      render :new
    end
  end

  def create_order
    product_id = params[:product_id]
    chat_id = params[:chat_id]
    product = Product.find(product_id)
    user = User.find_by(telegram_chat_id: chat_id)

    if product.quantity > 0
      @order = Order.create(
        product: product,
        user: user,
        state: 'unpaid',
        cancelable_until: 24.hours.from_now
      )

      if @order.persisted?
        product.decrement_quantity!(1)
        total_due = calculate_total_due(user)
        message = "✅ Заказ оформлен!\n🚚Заказ: #{product.name} - #{product.price} ₽\n💳💵Итого долг: #{total_due} ₽"
        send_telegram_message(chat_id, message)
        render json: { status: 'Заказ создан и сообщение отправлено в Telegram' }
      else
        render json: { status: 'Ошибка в создании заказа' }, status: :unprocessable_entity
      end
    else
      render json: { status: 'Продукта нет в наличии' }, status: :unprocessable_entity
    end
  end


  def archived
    @orders = Order.only_deleted.includes(:user, :product)
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_path, notice: 'Заказ архивирован'
  end

  def really_destroy
    @order = Order.only_deleted.find(params[:id])
    @order.really_destroy!
    redirect_to archived_orders_path, notice: 'Заказ удален'
  end

  private

  def order_params
    params.require(:order).permit(:product_id, :user_id)
  end


  def send_telegram_message(chat_id, message)
    token = Rails.application.credentials.dig(:telegram, :bot, :token)
    Telegram::Bot::Client.new(token).tap do |bot|
      bot.send_message(chat_id: chat_id, text: message)
    end
  end

  def calculate_total_due(user)
    total_price = user.orders.where(state: 'unpaid').joins(:product).sum('products.price')
    total_due = total_price - user.deposit
    total_due < 0 ? 0 : total_due
  end
end
