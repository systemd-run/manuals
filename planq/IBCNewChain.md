Будет рассмотрена настройка IBC между Planq и новой сетью на примере Kujira.
## Редактирование конфига Hermes
В конфигурационный файл hermes (.hermes/config.toml) добавляем конфиг для Kujira:
```
[[chains]]
id = 'kaiyo-1'
rpc_addr = 'https://kujira-rpc.polkachu.com:443'
grpc_addr = 'http://kujira-grpc.polkachu.com:11890'
websocket_addr = 'wss://rpc-kujira.starsquid.io:443/websocket'

rpc_timeout = '20s'
account_prefix = 'kujira'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 2000000
gas_price = { price = 0.00125, denom = 'ukuji' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 2000000
clock_drift = '45s'
max_block_time = '10s'
trusting_period = '10days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }
```
Конфиги для различных сетей можно найти на github.
## Добавление кошелька Umee
Восстанавливаем Umee кошелек:
```
MNEMONIC='...'
CHAIN_ID=kaiyo-1

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```
## Создание IBC Client, Connection, Channel
Здесь главное не запутаться и правильно подставлять полученные значения Client, Connection и Channel.

Создаем новый IBC Client:
1. Для Kujira:
```
hermes create client --host-chain kaiyo-1 --reference-chain planq_7070-2
```
В консоле отобразится созданный клиент вида: 07-tendermint-70
2. Для Planq:
```
hermes create client --host-chain planq_7070-2 --reference-chain kaiyo-1
```
В консоле отобразится созданный клиент вида: 07-tendermint-144
3. Обновляем созданные клиенты, подставляю полученные ранее значения клиентов (07-tendermint-70 и 07-tendermint-144):
```
hermes update client --host-chain kaiyo-1 --client 07-tendermint-70
```

```
hermes update client --host-chain planq_7070-2 --client 07-tendermint-144
```

Более подробно см. здесь: https://hermes.informal.systems/documentation/commands/path-setup/clients.html

Создаем новые Connection между Planq и Kujira:
1. Создаем Connection между Kujira и Planq со стороны Kujira:
```
hermes tx conn-init --dst-chain kaiyo-1 --src-chain planq_7070-2 --dst-client 07-tendermint-70 --src-client 07-tendermint-144
```
В консоле отобразится созданный Connection вида: connection-46
2. Создаем Connection между Kujira и Planq со стороны Planq, подставляя значение connection, полученное на предыдущем шаге:
```
hermes tx conn-try --dst-chain planq_7070-2 --src-chain kaiyo-1 --dst-client 07-tendermint-144 --src-client 07-tendermint-70 --src-connection connection-46
```
3. Подтверждаем создание Connection в первоначальном чейне, подставляя значения connection и клиентов, полученные на предыдущим шагах:
```
hermes tx conn-ack --dst-chain kaiyo-1 --src-chain planq_7070-2 --dst-client 07-tendermint-70 --src-client 07-tendermint-144 --dst-connection connection-46 --src-connection connection-151
```
4. Подтверждаем создание и открытие Connection, подставляя значения connection и клиентов, полученные на предыдущим шагах:
```
hermes tx conn-confirm --dst-chain planq_7070-2 --src-chain kaiyo-1 --dst-client 07-tendermint-144 --src-client 07-tendermint-70 --dst-connection connection-151 --src-connection connection-46
```
Более подробно и со схемой см. здесь: https://hermes.informal.systems/documentation/commands/tx/connection.html

Создаем новые Channel между Planq и Kujira:
1. Создание Channel между Kujira и Planq со стороны Kujira, подставляя ранее полученное значение connection:
```
hermes tx chan-open-init --dst-chain kaiyo-1 --src-chain planq_7070-2 --dst-connection connection-46 --dst-port transfer --src-port transfer
```
В консоле отобразится созданный Channel вида: channel-51
2. Создание Channel между Kujira и Planq со стороны Planq, подставляя ранее полученное значение connection и значение Channel (на предыдущем шагу):
```
hermes tx chan-open-try --dst-chain planq_7070-2 --src-chain kaiyo-1 --dst-connection connection-151 --dst-port transfer --src-port transfer --src-channel channel-51
```
В консоле отобразится созданный Channel вида: channel-23
3. Подтверждаем создание Channel в первоначальном чейне, подставляя значения Channel и Connection, полученные на предыдущим шагах:
```
hermes tx chan-open-ack --dst-chain kaiyo-1 --src-chain planq_7070-2 --dst-connection connection-46 --dst-port transfer --src-port transfer --dst-channel channel-51 --src-channel channel-23
```
4. Подтверждаем создание и открытие Channel, подставляя значения Channel и Connection, полученные на предыдущим шагах:
```
hermes tx chan-open-confirm --dst-chain planq_7070-2 --src-chain kaiyo-1 --dst-connection connection-151 --dst-port transfer --src-port transfer --dst-channel channel-23 --src-channel channel-51
```
Более подробно и со схемой см. здесь: https://hermes.informal.systems/documentation/commands/tx/channel-open.html

## Дополнение конфига Hermes
После того, как у нас созданы каналы между Planq и Kujira необходимо открыть конфигурационный файл Hermes:
```
nano .hermes/config.toml
```
В блоке настройками Planq в [chains.packet_filter] добавить следующее:
```
  ['transfer', 'channel-23'], # kujira
```
Т.е. указываем, полученный ранее канал.

В блоке настройками Kujira в [chains.packet_filter] добавить следующее:
```
[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-51'], # Planq
]
```

Перезагружаем Hermes, смотрим, что все нормально стартануло6
```
sudo systemctl restart hermesd && journalctl -u hermesd -f -o cat
```
## Проверка
Отправляем транзацию из Planq в Kujira:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain kaiyo-1 --src-chain planq_7070-2 --src-port transfer --src-channel channel-23 --amount <ammount planq> --denom aplanq
```
Отправляем транзацию из Kujira в Planq.</br>
Предварительно нам нужно узнать denom монеты Planq в сети Kujira. Узнать можно, например, в эксплорере, denom вида ibc/F2A6A3D4C02E003CC3EDB84CFD1C6F8F0E21EE6815575C5FE82FAC7D96106239.
При это denom чувтсвителен к регистру, приставка "ibc" должна быть указана строчными буквами.
Пример транзации:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain planq_7070-2 --src-chain kaiyo-1 --src-port transfer --src-channel channel-51 --amount 10 --denom ibc/F2A6A3D4C02E003CC3EDB84CFD1C6F8F0E21EE6815575C5FE82FAC7D96106239
```
