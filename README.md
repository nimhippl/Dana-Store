# Dana Store

## Requirements and setup

1. Clone this project

2. Create file `.env` in the root directory and add PostgreSQL login and password for development environment
    ```
    DATABASE_USER=<your_login>
    DATABASE_PASSWORD=<your_password>
    ```

3. Setup the project:
    ```
    bundle install
    yarn install
    bundle exec rake db:create
    bundle exec rake db:migrate
    ```

4. Start
    ```
    sudo service postgresql start
    bin/dev
    ngrok start --all
    rails telegram:bot:poller
    ```


5. Bot
    `https://t.me/yup_pi_bot`

      


# Dana Store

## Требования и настройка

1. Склонируйте этот проект

2. Создайте файл `.env` в корневом каталоге и добавьте логин и пароль PostgreSQL для среды разработки
    ```
    DATABASE_USER=<your_login>
    DATABASE_PASSWORD=<your_password>
    ```

3. Настройте проект:
    ```
    bundle install
    yarn install
    bundle exec rake db:create
    bundle exec rake db:migrate
    ```

4. Запустите
    ```
   sudo service postgresql start
   bin/dev
   ngrok start --all
   rails telegram:bot:poller
   ```


5. Бот
   `https://t.me/yup_pi_bot`
