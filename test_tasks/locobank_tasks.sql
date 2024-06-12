/* Задание 1. Необходимо "подготовить базу для рассылки СМС".

На выходе требуется вывести существующие поля:
+ client_id, hash_id, rest_rub, tarif_name, tel_num;

И расчетные поля:
- Текст сообщения (sms_text) -> а где данные, в ТЗ нет ничего.
+ месяц активации(число от 1 до 12),
+ остаток на счете, округленный до тысяч рублей
+ со 2 по 4  символы номера телефона (телефон хранится как текст)
- Описание клиентского сегмента - владельцы карты с тарифом (tarif_name) "амурский тигр", активировавшие карту(date_activated) во втором квартале 2016 года, имеющие на счете карты(acc_num) по состоянию на 2016-07-01(report_date) остаток (rest_rub) не менее 1000 рублей.
- Последний отмеченный статус по карте - "open". Исключить клиентов из "черного списка".  Если у клиента несколько карт, подходящих под условия - выбрать карту с максимальным остатком.
- Клиентам, у которых номер телефона заканчивается на четное число направить текст начинающийся с обращения по имени отчеству, тем у кого на нечетное "сообщение с суммой остатка карты", выделить в каждой группе по 15% клиентов для контрольной группы

- Результирующую таблицу сформировать с произвольным именем в текущей БД, записав все данные
*/

create table loco_results_1 as
with
    clietns as (
        select
            card.client_id, card.hash_id,
            acc.rest_rub, acc.report_date,
            cat.tarif_name,
            tel.tel_num,

            cast(substr(card.date_activated, 6,2) as integer) as month_activated,
            round(acc.cum_sum) as round_cum_sum_rub,
            substr(tel.tel_num, 2, 3) as sample_tel
        from loco_cards as card
        left join (select
                       acc_num, report_date, rest_rub,
                       row_number() over (partition by acc_num order by report_date desc) as latest_rest,
                       sum(rest_rub) over(partition by acc_num order by report_date asc) as cum_sum
                   from loco_accounts) as acc on card.acc_num == acc.acc_num
        left join loco_catalog as cat on card.tarif_id == cat.tarif_id
        left join loco_tel_catalog as tel on card.client_id == tel.client_id
        left join loco_black_list as black on card.client_id == black.client_id
        where acc.latest_rest == 1
            and black.client_id is null
    )

select * from clietns

/* Задание 2
Записать в таблицу comms:
	- Client_id из результирующей таблицы задания 1
	- Дату коммуникации (сегодняшнюю)
	- Количество дней прошедшее с момента коммуникации до записи в таблицу
 */

INSERT INTO loco_comms (client_id, comm_date, days_pass)
select
    client_id, comm_date,
    julianday(date('now')) - julianday(date(comm_date)) AS days_pass
from loco_comms
where client_id in (select client_id from loco_results_1);








