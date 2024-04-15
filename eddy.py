#!/usr/bin/env python3

from typing import List
from sys import exit
import fileinput
import sys
import re

def print_info(msg: str):
    """ Prints the given message to the standard error stream and exits the program.

    Args:
        msg (str): The message to be printed.
    """
    sys.stderr.write('{}\n'.format(msg))
    exit(1)

delete_comment_re = re.compile(r'\s+#.*$')

def delete_comment(s: str) -> str:
    """ Removes comments from a given string.

    Args:
        s (str): The input string that may contain comments.

    Returns:
        str: The input string with comments removed.
    """
    if s.strip().startswith('#'):
        return ''
    else:
        return delete_comment_re.sub('', s)
    
split_cmd_re = re.compile(r'[;\n]')

def preprocess_script(scripts, is_file) -> List[str]:
    """ Preprocesses a script by removing comments and splitting it into a list of patterns.

    Args:
        scripts (str): The input script or file path.
        is_file (bool): Indicates whether the input is a file path.

    Returns:
        list: A list of patterns extracted from the script.
    """
    if is_file:
        with open(scripts, 'r') as f:
            scripts = f.read()
    pattern_list = split_cmd_re.split(scripts)                                      # Split the script into a list of patterns
    pattern_list = [delete_comment(p) for p in pattern_list]                        # Remove comments from each pattern
    pattern_list = [p.strip() for p in pattern_list if len(p) != 0]                 # Remove leading and trailing whitespace and filter out empty patterns
    return pattern_list

class AddressCommandStruct:
    def __init__(self, classification, command, address=None, pattern=None):
        """ Initializes an instance of AddressCommandStruct.

        Args:
            classification (str): The classification of the address command.
            command (str): The command associated with the address.
            address (Optional): The address value (default: None).
            pattern (Optional): The pattern value (default: None).

        Attributes:
            classification (str): The classification of the address command.
            command (str): The command associated with the address.
            address: The address value.
            pattern: The pattern value.
        """
        self.classification: str = classification
        self.command: str = command
        self.address = address
        self.pattern = pattern


address_command_patterns = [                                            # line: line number, re: regular expression
    re.compile(r'(\d+|\$)\s*,\s*(\d+|\$)\s*(.)\s*(.*?)$'),              # line_line
    re.compile(r'/\s*(.+?)\s*/\s*,\s*/\s*(.+?)\s*/\s*(.)\s*(.*?)$'),    # re_re
    re.compile(r'(\d+|\$)\s*,\s*/\s*(.+?)\s*/\s*(.)\s*(.*?)$'),         # line_re
    re.compile(r'/\s*(.+?)\s*/\s*,\s*(\d+|\$)\s*(.)\s*(.*?)$'),         # re_line
    re.compile(r'/\s*(.+?)\s*/\s*(.)\s*(.*?)$'),                        # re
    re.compile(r'(\d+|\$)\s*(.)\s*(.*?)$'),                             # line
    re.compile(r'(.)\s*(.*)$')                                          # cmd
]

def split_address_command(cmd: str) -> AddressCommandStruct:
    """ Splits an address command string into its components and returns an instance of AddressCommandStruct.

    Args:
        cmd (str): The address command string to be split.

    Returns:
        AddressCommandStruct: An instance of AddressCommandStruct representing the address command.
    """
    for idx, pattern in enumerate(address_command_patterns):
        match = pattern.match(cmd)
        if match:
            return AddressCommandStruct(
                ['line_line', 're_re', 'line_re', 're_line', 're', 'line', None][idx],                      # Determine the classification based on the index
                match.group(3) if idx < 4 else (match.group(1) if idx == 6 else match.group(2)),            # Extract the command based on the index
                (match.group(1), match.group(2)) if idx < 4 else (None if idx == 6 else match.group(1)),    # Extract the address based on the index
                match.group(4) if idx < 4 else (match.group(2) if idx == 6 else match.group(3)),            # Extract the pattern based on the index
            )
    return None

is_quit = False
s_cmd_re = re.compile(r'(\S)(.*?)\1(.*?)\1([g]?)$')

def process_command(line: str, cmd: str, pattern: str, address):
    """ Process a command on a given line based on the specified command, pattern, and address.

    Args:
        line (str): The input line to process.
        cmd (str): The command to execute.
        pattern (str): The pattern to use for searching or replacing.
        address: The address to specify the line(s) to operate on.

    Returns:
        str: The processed line after applying the command, or None if the command is 'd'.
    """
    global is_quit
    if cmd == 'p':
        if address is None and line is not None:
            print(line)
        elif address is not None and line:
            print(line)
    elif cmd == 'd':
        return None
    elif cmd == 's':
        match = s_cmd_re.match(pattern)
        if match:
            search, replace, flag = match.group(2), match.group(3), 0 if match.group(4) == 'g' else 1
            return re.sub(search, replace, line, count=flag)
        else:
            print_info('process_command: s no pattern.')
    elif cmd == 'q':
        if line is not None:
            is_quit = True
    else:
        print_info('process_command: unknow pattern.')
        
    return line

re_re_start_line = {'p': sys.maxsize, 's': sys.maxsize, 'd': sys.maxsize}
re_re_end_line = {'p': sys.maxsize, 's': sys.maxsize, 'd': sys.maxsize}
re_line_start_line = {'p': sys.maxsize, 's': sys.maxsize, 'd': sys.maxsize}
line_re_end_line = {'p': sys.maxsize, 's': sys.maxsize, 'd': sys.maxsize}

def process_line(line, address_command_list: List[AddressCommandStruct], current_line_number: int, is_auto_print, is_end: bool):
    """ Processes a line based on the address commands and current line number.

    Args:
        line (str): The input line to process.
        address_command_list (List[AddressCommandStruct]): List of address commands.
        current_line_number (int): The current line number.
        is_auto_print: (bool): Whether automatic printing is enabled.
        is_end (bool): Whether the end of the input is reached.
    """
    global is_quit
    global re_re_start_line
    global re_re_end_line
    global re_line_start_line
    global line_re_end_line

    for ac in address_command_list:
        is_quit = False
        if ac.classification is None:                                                           # 0 cmd
            line = process_command(line, ac.command, ac.pattern, ac.address)
        elif ac.classification == 'line':                                                       # 1 line_number, cmd
            if ac.address == '$':
                if is_end:
                    line = process_command(line, ac.command, ac.pattern, ac.address)
                    continue
            elif current_line_number == int(ac.address):
                line = process_command(line, ac.command, ac.pattern, ac.address)
        elif ac.classification == 'line_line':                                                  # 2 start_line, end_line, cmd
            if ac.address[1] == '$':
                end_line = sys.maxsize
            else:
                end_line = int(ac.address[1])

            if ac.address[0] == '$':
                if is_end:
                    line = process_command(line, ac.command, ac.pattern, ac.address)
                continue
            else:
                start_line = int(ac.address[0])

            if start_line == current_line_number:
                line = process_command(line, ac.command, ac.pattern, ac.address)
            elif current_line_number > start_line and current_line_number <= end_line:
                line = process_command(line, ac.command, ac.pattern, ac.address)
        elif ac.classification == 're':                                                         # 3 RE, cmd
            match = re.search(ac.address, line)
            if match:
                line = process_command(line, ac.command, ac.pattern, ac.address)
        elif ac.classification == 're_re':                                                      # 4 start_RE, end_RE, cmd
            if re_re_start_line[ac.command] == sys.maxsize:
                if re.search(ac.address[0], line):
                    re_re_start_line[ac.command] = current_line_number
            if re.search(ac.address[1], line):
                re_re_end_line[ac.command] = current_line_number

            if re_re_start_line[ac.command] >= re_re_end_line[ac.command]:
                re_re_end_line[ac.command] = sys.maxsize
            
            if re_re_start_line[ac.command] == current_line_number:
                line = process_command(line, ac.command, ac.pattern, ac.address)
            elif current_line_number > re_re_start_line[ac.command] and current_line_number <= re_re_end_line[ac.command]:
                line = process_command(line, ac.command, ac.pattern, ac.address)
                if current_line_number == re_re_end_line[ac.command]:
                    re_re_start_line[ac.command] = sys.maxsize
                    re_re_end_line[ac.command] = sys.maxsize
        elif ac.classification == 're_line':                                                    # 5 start_RE, end_line, cmd
            if re.search(ac.address[0], line):
                re_line_start_line[ac.command] = current_line_number

            if ac.address[1] == '$':
                end_line = sys.maxsize
            else:
                end_line = int(ac.address[1])

            if re_line_start_line[ac.command] == current_line_number:
                line = process_command(line, ac.command, ac.pattern, ac.address)
            elif current_line_number > re_line_start_line[ac.command] and current_line_number <= end_line:
                line = process_command(line, ac.command, ac.pattern, ac.address)
        elif ac.classification == 'line_re':                                                    # 6 start_line, end_RE, cmd
            if ac.address[0] == '$':
                if is_end:
                    line = process_command(line, ac.command, ac.pattern, ac.address)
                continue
            else:
                start_line = int(ac.address[0])

            if line_re_end_line[ac.command] == sys.maxsize and re.search(ac.address[1], line):
                line_re_end_line[ac.command] = current_line_number

            if start_line >= line_re_end_line[ac.command]: # 3,/2/
                line_re_end_line[ac.command] = sys.maxsize
            
            if current_line_number >= start_line and current_line_number <= line_re_end_line[ac.command]:
                line = process_command(line, ac.command, ac.pattern, ac.address)     
        else:
            print_info('process_line: unkonw classification.')

        if is_quit:
            break

    if is_auto_print and line is not None:
        print(line)

    if is_quit:
        exit(0)

def process_input(address_command_list: List[AddressCommandStruct], is_auto_print: bool, input_stream=None):
    """ Processes input lines based on the address commands and options.

    Args:
        address_command_list (List[AddressCommandStruct]): List of address commands.
        is_auto_print (bool): Whether automatic printing is enabled.
        input_stream: The input stream to read lines from. If None, sys.stdin is used.
    """
    if input_stream is None:
        input_stream = sys.stdin

    current_line = next(input_stream).strip()
    current_line_number = 1
    is_end = False
    while True:
        try:
            next_line = next(input_stream).strip()
        except Exception:
            is_end = True

        process_line(current_line, address_command_list, current_line_number, is_auto_print, is_end)

        if is_end:
            break

        current_line = next_line
        current_line_number += 1

def process_args():
    """ Process command-line arguments.

    Returns:
        args (dict): A dictionary containing the processed arguments.

                     - 'n' (bool): Indicates whether automatic printing of pattern space is suppressed.

                     - 'f' (str or None): The script file to be executed, or None if not provided.

                     - 'patterns' (str or None): The sed command to be executed, or None if not provided.

                     - 'files' (list or None): List of files to process, or None if not provided.
    """
    args = {}
    args['n'] = False if '-n' in sys.argv[1:] else True
    if '-f' in sys.argv[1:]:
        index = sys.argv.index('-f')
        if index < len(sys.argv) - 1:
            args['f'] = sys.argv[index + 1]
        else:
            print_info('no script-file')
    else:
        args['f'] = None

    posittion_args = [arg for arg in sys.argv[1:] if arg not in ['-n', '-f', args.get('f', '')]]
    if '-f' not in sys.argv[1:]:
        args['patterns'] = posittion_args[0]
        is_f = 1
    else:
        args['patterns'] = None
        is_f = 0

    if len(posittion_args) - is_f > 0:
        args['files'] = posittion_args[is_f:]
    else:
        args['files'] = None

    return args

    # # python3 eddy.py [-n] [-f <script-file> | --patterns/-p <sed-commands>] [files...]
    #
    # import argparse
    # parser = argparse.ArgumentParser(description='a simple subset of the important tool sed')
    # parser.error = lambda err: print_info('process_args: {}'.format(err)) # Define a custom error handling function
    # parser.add_argument('-n', action='store_false', help='suppress automatic printing of pattern space')
    # script_group = parser.add_mutually_exclusive_group(required=True)
    # script_group.add_argument('-f', metavar='script-file', nargs='?', help='add the contents of script-file to the commands to be executed')
    # script_group.add_argument('--patterns', '-p', metavar='sed-command', nargs='?', help='sed-command (q, p, d or s)')
    # parser.add_argument('files', nargs='*', help='files to process')
    # return parser.parse_args()

def main():
    args = process_args()

    pattern_list = preprocess_script(args['f'], True) if args['f'] else preprocess_script(args['patterns'], False)
    address_command_list = [split_address_command(pattern) for pattern in pattern_list]

    # # debug print
    # print('print address_command_list')
    # print('-' * 120)
    # print('{:<20}\t|\t{:<20}\t|\t{:<20}\t|\t{:<30}'.format('classification', 'address', 'command', 'pattern'))
    # for ac in address_command_list:
    #     print('{:<20}\t|\t{:<20}\t|\t{:<20}\t|\t{:<30}'.format(
    #         '' if ac.classification is None else ac.classification,
    #         '' if ac.address is None else ('({},{})'.format(ac.address[0], ac.address[1]) if isinstance(ac.address, tuple) else ac.address),
    #         ac.command,
    #         ac.pattern
    #     ))
    # print('-' * 120)

    try:
        file_stream = fileinput.input(args['files']) if args['files'] else None
        process_input(address_command_list, args['n'], file_stream)
    except (FileNotFoundError, PermissionError, KeyboardInterrupt, Exception) as e:
        print_info(e)

if __name__ == '__main__':
    main()