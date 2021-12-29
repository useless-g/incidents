from connection import MySQL, ExecuteError
import datetime


def protocol_incident():

    try:
        id = int(input("Введите номер происшествия: "))
        if id <= 0:
            raise ValueError
    except ValueError:
        print('Неверные данные')
        return

    with open(f"происшествие №{id}.txt", 'w') as f:
        f.write(mysql.print_table(f"""SELECT * FROM incident WHERE id = {id};""",
                                  ['id', 'дата', 'тип', 'решение']))
        f.write("\n\tЛИЦА ЗАДЕЙСТВОВАННЫЕ В ПРОИСШЕСТВИИ\n")
        f.write(mysql.print_table(f"""SELECT p.id, p.фамилия, p.имя, p.отчество, p.адрес, p.судимости, i.role
                                        FROM person p LEFT JOIN involvement i
                                        ON p.id = i.person_id
                                        WHERE i.incident_id = {id};""",
                                  ['id', 'фамилия', 'имя', 'отчество', 'адрес', 'судимости', 'роль']))


def amount_in_time():
    start = input('Введите дату начала отрезка в виде YYYY-MM-DD: ')
    finish = input('Введите дату конца отрезка в виде YYYY-MM-DD: ')
    try:
        start = datetime.date.fromisoformat(start)
        finish = datetime.date.fromisoformat(finish)
        mysql.print_table(f"SELECT amount_in_time('{start}', '{finish}');",
                          [f'между {start} и {finish} произошло происшествий'])
    except ValueError:
        print('Неправильно введена дата! ')


def amount_for_person():
    try:
        id = int(input('Введите регистрационный номер участника происшествия: '))
    except ValueError:
        print('Введите целое положительное число! ')
        return
    mysql.print_table(f"SELECT amount_for_person({id});", [f'всего происшествий зарегестрированных на {id}'])


def insert_incident():
    args = input('Введите (id, date, type, decision) через пробел: ').split(' ')
    try:
        args[1] = datetime.date.fromisoformat(args[1])
        mysql.execute(f"CALL insert_incident({args[0]}, '{args[1]}', '{args[2]}', '{args[3]}');")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


def insert_person():
    args = input('Введите id , фамилия, имя, отчество, адрес, судимости через пробел: ').split(' ')
    try:
        mysql.execute(f"CALL insert_person({args[0]}, '{args[1]}', '{args[2]}', '{args[3]}', '{args[4]}', {args[5]});")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


def insert_involvement():
    args = input('Введите person_id, incident_id, role через пробел: ').split(' ')
    try:
        mysql.execute(f"CALL insert_involvement({args[0]}, {args[1]}, {args[2]});")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


def update_incident():
    args = input('Введите id записи, которую хотите изменить и новые date, type, decision через пробел: ').split(' ')
    try:
        args[1] = datetime.date.fromisoformat(args[1])
        mysql.execute(f"CALL update_incident({args[0]}, '{args[1]}', '{args[2]}', '{args[3]}');")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


def update_person():
    args = input('Введите id записи, которую хотите изменить и новые фамилия, имя, отчество, адрес, судимости через пробел: ').split(' ')
    try:
        mysql.execute(f"CALL update_person({args[0]}, '{args[1]}', '{args[2]}', '{args[3]}', '{args[4]}', {args[5]});")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


def update_involvement():
    args = input('Введите person_id, incident_id записи, которую хотите изменить и новую role через пробел: ').split(' ')
    try:
        mysql.execute(f"CALL update_involvement({args[0]}, {args[1]}, {args[2]});")
    except (ValueError, ExecuteError, IndexError):
        print('Некорректные данные! ')


if __name__ == '__main__':
    while True:
        try:
            log, password = input('Ведите логин и пароль через пробел: ').split(' ')
            mysql = MySQL(log, password)
            break
        except Exception:
            print('Неверный логин или пароль! ')

    while log == 'root':
        sql = input('Введите запрос: ')
        if sql == '0':
            break
        mysql.print_table(sql)
    while log != 'root':
        print("""
    0) закончить работу
    1) создать и вывести протокол происшествия
    2) вывести количество происшествий за отрезок времени
    3) вывести количество зарегистрированных на человека происшествий
    4) внести информацию о новом происшествии
    5) внести информацию о новом участнике происшествия
    6) внести информацию об участии человека в происшествии
    7) обновить информацию о происшествии
    8) обновить информацию об участнике происшествия
    9) обновить информацию об участии человека в происшествии
        """)
        try:
            string = int(input("Введите номер команды: "))
            if not (0 <= string <= 9):
                raise ValueError
        except ValueError:
            print('Неверные данные')
            continue
        if string == 0:
            break
        elif string == 1:
            protocol_incident()
        elif string == 2:
            amount_in_time()
        elif string == 3:
            amount_for_person()
        elif string == 4:
            insert_incident()
        elif string == 5:
            insert_person()
        elif string == 6:
            insert_involvement()
        elif string == 7:
            update_incident()
        elif string == 8:
            update_person()
        elif string == 9:
            update_involvement()

    del mysql
    input('Goodbye!!!')
