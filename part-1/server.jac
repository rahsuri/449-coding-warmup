import:py from datetime {datetime}

walker interact {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker interact_with_body {
    has name: str;

    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}

# My walkers

walker interact_multiply {
    has num1: int;
    has num2: int;

    can return_message with `root entry {
        report {
            "response": "The product of " + str(self.num1) + " and " + str(self.num2) + " is " + str(self.num1 * self.num2)
        };
    }
}

walker interact_with_time {
    can return_message with `root entry {
        report {
            "response": "The current time is " + datetime.now().strftime("%H:%M:%S")
        };
    }
}

