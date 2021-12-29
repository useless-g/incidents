import mysql.connector
from tabulate import tabulate


class ExecuteError(Exception):
    pass


class MySQL:
    """
    Основной класс для работы с MySQL.
    """

    def __init__(self, login, password):
        # try:
        self.db = mysql.connector.connect(host="127.0.0.1", user=login, passwd=password, db="car_service", charset='utf8')
        # except ExecuteError:
        #     pass
        self.cursor = self.db.cursor()

    def execute(self, sql):
        """
        Выполняет SQL запрос.
        """
        execute_error = False
        try:
            self.cursor.execute(sql)
        except Exception as e:
            execute_error = True
            print(e)

        if execute_error:
            print('ExecuteError: ошибка в запросе ')
            return

        return self.cursor.fetchall()

    def print_table(self, sql, head):
        res = tabulate(self.execute(sql), headers=head, tablefmt='psql')
        print(res)
        return res

    def __del__(self):
        if self.__dict__.get('cursor'):
            self.cursor.close()
            self.db.commit()
