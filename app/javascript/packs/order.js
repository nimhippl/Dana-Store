import { FetchRequest } from '@rails/request.js';
import "../../assets/stylesheets/application.tailwind.css";


async function orderProduct(button) {
    const productId = button.getAttribute('data-product-id');
    const chatId = button.getAttribute('data-chat-id');

    const request = new FetchRequest('post', '/create_order', {
        body: JSON.stringify({ product_id: productId, chat_id: chatId }),
        contentType: 'application/json',
    });

    const response = await request.perform();
    if (response.ok) {
        const body = await response.json();
        console.log(body);
    } else {
        console.error('Order creation failed');
    }
}

window.orderProduct = orderProduct;
