class TelegramWebhookController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::Session


  def start!(*)
    telegram_chat_id = from['id']
    telegram_username = from['username']

    user = User.with_deleted.find_or_create_by(telegram_chat_id: telegram_chat_id) do |u|
      u.telegram_username = telegram_username
      u.username = 'employee'
      u.password = SecureRandom.hex(10)
    end

    if user.deleted_at
      user.restore
      user.update(status: :pending)
    end

    employee_role = Role.find_or_create_by(name: 'employee')

    unless user.roles.include?(employee_role)
      user.roles << employee_role
      user.save!
    end

    if user.pending?
      respond_with :message, text: "Привет, #{telegram_username}! 👋"
      respond_with :message, text: 'Мы отправили запрос на подключение нашему офис-менеджеру. Пока ждешь уведомление о подключении, можешь выпить чашечку кофе ☕'
    elsif user.active?
      send_menu_button(telegram_chat_id)
    end
  end

  def callback_query(data)
    case data
    when 'show_menu'
      send_categories
    else
      if data.start_with?('category_')
        category_id = data.split('_').last.to_i
        send_products(category_id)
      elsif data.start_with?('order_')
        product_id = data.split('_').last.to_i
        create_order(product_id)
      end
    end
  end

  private


  def send_menu_button(chat_id)
    ngrok_url = Rails.application.credentials.dig(:telegram, :bot, :ngrok_url)
    kb = [
      [{ text: 'Открыть меню', web_app: { url: "#{ngrok_url}/web_app?chat_id=#{chat_id}" } }]
    ]
    respond_with :message, text: 'Открой меню, чтобы увидеть весь ассортимент:', reply_markup: { inline_keyboard: kb }
  end

  def send_categories
    categories = Category.all
    kb = categories.map do |category|
      { text: category.name, callback_data: "category_#{category.id}" }
    end.each_slice(2).to_a
    respond_with :message, text: 'Выберите категорию:', reply_markup: { inline_keyboard: kb }
  end

  def send_products(category_id)
    category = Category.find(category_id)
    products = category.products.where('quantity > 0')

    if products.any?
      kb = products.map do |product|
        { text: "#{product.name}: #{product.price} руб. (в наличии: #{product.quantity})", callback_data: "order_#{product.id}" }
      end.each_slice(2).to_a

      respond_with :message, text: "*#{category.name}*\nВыберите продукт:", reply_markup: { inline_keyboard: kb }, parse_mode: 'Markdown'
    else
      respond_with :message, text: "В категории *#{category.name}* нет доступных продуктов.", parse_mode: 'Markdown'
    end
  end

  def create_order(product_id)
    chat_id = from['id']
    params = ActionController::Parameters.new(product_id: product_id, chat_id: chat_id)
    OrdersController.action(:create_order).call(request.env.merge('action_dispatch.request.parameters' => params))
  end
end
