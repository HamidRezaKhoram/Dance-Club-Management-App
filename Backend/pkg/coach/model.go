package coach

import "gorm.io/gorm"

type Coach struct {
	gorm.Model
	Name        string `json:"name"`
	Email       string `json:"email" gorm:"index;unique"`
	PhoneNumber int    `json:"phone_number"`
	Password    string `json:"password"`
	Owed        int    `json:"owed"`
}

type CoachPayment struct {
	Id     int `json:"id"`
	Amount int `json:"amount"`
}
