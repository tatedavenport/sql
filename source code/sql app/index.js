const http = require('http');
const path = require('path');
const fs = require('fs');
const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const crypto = require('crypto');
const bodyParser = require('body-parser');




if (process.argv.slice(2).length < 2) {
    console.log('Need a database username and password');
    process.exit();
}

//create sql connection
var connection = mysql.createConnection({
    host: 'localhost',
    user: process.argv.slice(2)[0],
    password: process.argv.slice(2)[1],
    insecureAuth: true
})


connection.connect(err => {
    if (err) {
        console.log(err);
        process.exit();
    } else {
        console.log('Connected to database');
    }
});
connection.query('use cs4400spring2020', ()=> console.log('Using cs4400spring2020'));

//create server object
const app = express();

//template engine
app.set('view engine', 'ejs');

const PORT = process.env.PORT || 5000;

//for json data
app.use(bodyParser.urlencoded());
app.use(bodyParser.json());
//in case of cors error
app.use(cors());

//register error object, don't need balance or password ones because they can be handled front end
registerError = {
    usernameError: "",
    emailError: "",
    nameError: "",
    sqlError: "",
    mbasError: "",
    createBuildingError:"",
    updateBuildingError:"",
    createStationError:"",
    updateStationError:"",
    manageFoodError:"",
    createFoodError:"",
    createFoodTruckError:"",
    mfError:"",
    ftsError:"",
    exploreError:"",
    ciError:"",
    orderError:"",
    historyError:"",
    deleteFoodError:"",
}

function resetRegisterError() {
    for (const property in registerError) {
        registerError[property] = ""; //before rendering the register screen, make sure there aren't any existing errors left over
    };
}


//routes

//login, screen 1
app.post('/login', (req, res) =>{
    resetRegisterError();
    data = req.body;
    console.log(req.body);
    data.registerError = registerError;
    if (!data.register) {
        //use stored procedure
        connection.query(`call login('${data.usernameValue}', '${data.password}');`, (e, results, fields)=>{
            //check that e is NULL; if it is, no error; otherwise, error
            if (e) {
                console.log(e);
                res.sendFile(path.join(__dirname, 'public', 'index_error.html')); //this is good
            } else {
               //res.sendFile(path.join(__dirname, 'public', 'home.html')); //this will be the home screen once i make it
               res.render('home', data);
            }
        });
    } else {
        resetRegisterError();
        res.render('register', data);
    }
});

//register, screen 2 and 3
app.post('/register', (req, res)=>{
    data = req.body;
    resetRegisterError();
    connection.query('select * from `user`', (e, results, fields)=>{
        //check results for username
        let shouldRegister = false;
        for (const resultVal of results) {
            if (resultVal.username === data.usernameValue) {
                registerError.usernameError = "Username already taken";
                data.registerError = registerError;
                res.render('register', data);
            } else if (data.email != "" && resultVal.email === data.email) {
                registerError.emailError = "Email already taken";
                data.registerError = registerError;
                res.render('register', data);
            } else if (data["First Name"] === resultVal.firstName && data["Last Name"] === resultVal.lastName) {
                registerError.nameError = "Name exsists already";
                data.registerError = registerError;
                res.render('register', data);
            } else {
                //register
                shouldRegister = true;
            }
        }
        if (data.Balance==="") {
            data.Balance="NULL"
        }
        let callLine;
        if (data.employeeType === undefined || data.employeeType=== "None") {
            callLine = `call register('${data.usernameValue}','${data.email}', '${data['First Name']}', '${data['Last Name']}', '${data.Password}', ${data.Balance}, NULL);`
        } else {
            callLine = `call register('${data.usernameValue}','${data.email}', '${data['First Name']}', '${data['Last Name']}', '${data.Password}', ${data.Balance}, '${data.employeeType}');`
        };
        connection.query(callLine, (e, results, fields)=>{
           if (e) {
               console.log(e);
               registerError.sqlError="Duplicate Email"
               //remove user
               connection.query(`delete from user where username="${req.body.usernameValue}"`, (e, results, fields)=>{
                   if (e) {
                       console.log(e);
                   } else {
                     data.registerError = registerError;
                        res.render('register', data)
                   }
               })
           } else {
                //registration successful, load home with username
                resetRegisterError();
                res.render('home', data);
           }
        }); 
    });

});

//for managebuildingandstation
app.post('/managebuildingandstationpage', (req, res)=>{
    //first check if admin, if not then render home screen with correct error
    //need to append input with value as user input on home for right form
    const currentUser = req.body.currentUser;
    connection.query('select * from `admin`', (e, results, fields)=> {
        
        let isAdmin=false;
        for (result of results) {
            if (result.username === currentUser) {
                isAdmin=true;
            }
        }

        if (isAdmin) {
            //is admin
            connection.query('select buildingName from building', (e1, buildings, buildingFields)=>{
                connection.query('select stationName from station', (e2, stations, stationFields)=>{
                    data = {};
                    data.buildings = buildings;
                    data.stations = stations;
                    data.usernameValue = currentUser;
                    res.render('managebuildingandstation', data); // gonna have to add in building and stations
                })
            })
        } else {
            //isn't admin
            resetRegisterError();
            registerError.mbasError="You aren't an admin";
            req.body.registerError = registerError;
            req.body.usernameValue = currentUser;
            res.render('home', req.body);
        }
    });
});

app.post('/managebuildingandstationfilter', (req, res)=> {
    //this one will actually send back json instead of rendering a page, client should handle creating table from json
    let callString;
    if (req.body.capacity1 === "" && req.body.capacity2 === "") {
        callString = `call ad_filter_building_station('${req.body.buildingName}', '${req.body.buildingTag}', '${req.body.stationName}', NULL, NULL)`;
    } else if (req.body.capacity1 ==="") {
        callString = `call ad_filter_building_station('${req.body.buildingName}', '${req.body.buildingTag}', '${req.body.stationName}', NULL, ${req.body.capacity2})`;
    } else {
        callString = `call ad_filter_building_station('${req.body.buildingName}', '${req.body.buildingTag}', '${req.body.stationName}', ${req.body.capacity1}, NULL)`;
    }
    connection.query(callString, (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            connection.query('select * from  ad_filter_building_station_result', (e, results2, fields)=> {
                res.end(JSON.stringify(results2));
            });
        }
    })
});

//this is for back buttons
app.post('/home', (req, res)=>{
    resetRegisterError();
    req.body.registerError = registerError;
    req.body.usernameValue = req.body.currentUser;
    res.render('home', req.body)
});

//create building stuff
app.post('/createbuildingpage', (req, res)=>{
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    res.render('createbuilding', req.body);
});

app.post('/createbuilding', (req, res)=>{
    connection.query(`call ad_create_building('${req.body.buildingName}', '${req.body.description}')`, (e, results1, fields1)=>{
        if (e) {
            console.log('Create building error');
            //building exists
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            registerError.createBuildingError = "Building Already Exists";
            req.body.registerError = registerError;
            res.render('createbuilding', req.body)
        } else {
            let tagArray = req.body.tags.split(',');
            tagArray.forEach((element)=>{
                elementTrim = element.trim();
                connection.query(`call ad_add_building_tag('${req.body.buildingName}','${elementTrim}')`, (eInner, results2, fields2)=>{
                    if(eInner) {
                        console.log('Tag insert error');
                    }
                })
            });
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            req.body.registerError = registerError;
            res.render('home', req.body)
        }
    })
});

//update building stuff
app.post('/updatebuildingpage', (req, res)=>{
    resetRegisterError();
    console.log(req.body);
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    //before we render we still need to get the building description and tags to add to the template
    const buildingName = Array.isArray(req.body.buildingName) ? req.body.buildingName[req.body.buildingName.length - 1] : req.body.buildingName;
    console.log(buildingName);
    const queryString = 'select * from (SELECT building.buildingName, description, group_concat(tag) as tags FROM cs4400spring2020.buildingtag right join building on buildingtag.buildingName = building.buildingName group by building.buildingName) as firstResult where firstResult.buildingName =' + '"' + buildingName + '"';
    connection.query(queryString, (e, results, fields)=>{
        if (results) {
            if (results[0]) {
                req.body.description = results[0].description;
                req.body.tags = results[0].tags;
            }
        }

        if (!req.body.description) {
            req.body.description = "";
        }
        if (!req.body.tags) {
            req.body.tags = "";
        }
        if (Array.isArray(req.body.buildingName)) {
            req.body.buildingName = req.body.buildingName[req.body.buildingName.length - 1];
        }
        res.render('updatebuilding', req.body);
    });
});

app.post('/updatebuilding', (req, res)=>{
    //update building, then render homepage with correct username and no errors
    connection.query(`call ad_update_building('${req.body.oldBuildingName}','${req.body.buildingName}','${req.body.description}')`, (e, results2, fields2)=>{
        if (e) {
            console.log(e)
            //new building name existed, render error
            resetRegisterError();
            registerError.updateBuildingError = "That building name exists already";
            req.body.usernameValue = req.body.currentUser;
            req.body.registerError = registerError;
            res.render('updatebuilding', req.body);
        } else {
            //before you render home you need to get rid of old tags and add new ones
            connection.query(`delete from buildingtag where buildingName="${req.body.buildingName}"`, (e, results, fields)=>{
                let tags = req.body.tags.split(',');
                tags.forEach((tag)=>{
                    tag = tag.trim();
                    connection.query(`insert into buildingtag values('${req.body.buildingName}','${tag}')`, (e2, results2, fields2)=>{
                        //don't need to do anything here
                        console.log(e2);
                    })
                })
                resetRegisterError();
                req.body.usernameValue = req.body.currentUser;
                req.body.registerError = registerError;
                res.render('home', req.body);
            })
        }
    })

});

//for creating stations
app.post('/createstationpage', (req, res)=>{
    resetRegisterError();
    req.body.registerError = registerError;
    req.body.usernameValue = req.body.currentUser;

    //get list of all available buildings
    buildings = [];
    const queryString = 'SELECT * FROM building where buildingName not in (select buildingName from station);';
    connection.query(queryString, (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            results.forEach((result)=>{
                buildings.push(result.buildingName);
            });
            req.body.buildings = buildings;
            res.render('createstation', req.body);
        }
    })
});

app.post('/createstation', (req, res)=>{
    //check if station name exists
    if (req.body.capacity === "") {
        req.body.capacity = 0;
    }
    connection.query(`call ad_get_available_building()`, (eNew, resultsNew, fieldsNew)=>{
        connection.query(`call ad_create_station('${req.body.name}','${req.body.buildingName}', ${req.body.capacity})`, (e, results, fields)=>{
            if (e) {
                console.log(e);
                let buildings = [];
                resetRegisterError();
                registerError.createStationError = "Station name exists";
                req.body.registerError = registerError;
                req.body.usernameValue = req.body.currentUser;
                //get available buildings again
                connection.query(`call ad_get_available_building()`, (e, results2, fields2)=>{
                    connection.query('select * from ad_get_available_building_result', (e, results3, fields3)=>{
                        results3.forEach((result)=>{
                            buildings.push(result.buildingName);
                        })
                        req.body.buildings = buildings;
                        res.render('createstation', req.body)
                    })
                })
            } else {
                resetRegisterError();
                req.body.usernameValue = req.body.currentUser;
                req.body.registerError = registerError;
                res.render('home', req.body);
            }
        });
    });
})

//for updating station
app.post('/updatestationpage', (req, res)=>{
    console.log(req.body);
    //get the station corresponding to this building
    //if none, then return to manage building and station page
    if (Array.isArray(req.body.buildingName)) {
        req.body.buildingName = req.body.buildingName[req.body.buildingName.length-1];
    }
    connection.query(`select * from building where buildingName not in (select buildingName from station)`, (e1, results1, fields1)=>{
        if (e1) {
            console.log(e1);
        } else {
            console.log(results1);
        }
        buildings = [];
        buildings.push(req.body.buildingName);
        results1.forEach((result)=>{
            buildings.push(result.buildingName);
        })
        console.log(buildings);
        connection.query(`call ad_view_station('${req.body.stationName}')`,(e2, results2, fields2)=>{
            if (e2) {
                console.log(e2);
            } else {
                connection.query(`select * from ad_view_station_result`, (e3, results3, fields3)=>{
                    if (e3) {
                        console.log(e3);
                    } else {
                        resetRegisterError();
                        req.body.capacity = results3[0].capacity;
                        req.body.usernameValue = req.body.currentUser;
                        req.body.registerError = registerError;
                        req.body.buildings = buildings;
                        res.render('updatestation', req.body);
                    }
                })
            }
        })
    })
})

app.post('/updatestation', (req, res)=>{
    //update station with data
    console.log(req.body);
    connection.query(`call ad_update_station('${req.body.name}',${req.body.capacity},'${req.body.buildingName}')`, (e, results, fields) => {
        if (e) {
            console.log(e);
        } else {
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            req.body.registerError = registerError;
            res.render('home', req.body);
        }
    })
});

//delete station
app.post('/deletestation1', (req, res)=>{
    //need to get station name
    connection.query(`select stationName from station where buildingName="${req.body.buildingName}"`, (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            data = {};
            if (results.length === 0) {
                //no station, respond with error
                data.response ="Error";
                res.end(JSON.stringify(data));
            } else {
                //respond with ok
                data.response ="OK";
                data.results = results;
                res.end(JSON.stringify(data));
            }
        }
    })
})

app.post('/deletestation2', (req, res)=>{
    connection.query(`call ad_delete_station('${req.body.stationName}')`, (e, results, fields)=>{
        if (e) {
            console.log(e);
            data = {response:"Error"};
            res.end(JSON.stringify(data));
        } else {
            data = {response:"OK", results};
            res.end(JSON.stringify(data));
        }
    })
})

//delete building
app.post('/deletebuilding', (req, res)=>{
    console.log(req.body);
    connection.query(`call ad_delete_building('${req.body.buildingName}')`, (e, results, fields)=>{
        data = {};
        if (e) {
            console.log(e);
            //return error
            data.response = "Error";
            res.end(JSON.stringify(data));
        } else {
            //return ok
            data.response = "OK";
            res.end(JSON.stringify(data));
        }
    })
})

//manage food stuff
app.post('/managefoodpage', (req, res)=>{
    let currentUser = req.body.currentUser;
    connection.query('select * from `admin`', (e, results, fields)=> {
        
        let isAdmin=false;
        for (result of results) {
            if (result.username === currentUser) {
                isAdmin=true;
            }
        }

        if (isAdmin) {
            //is admin
            connection.query('select foodName from food', (e1, foods, buildingFields)=>{
                req.body.foods = foods;
                req.body.usernameValue = currentUser;
                res.render('managefood', req.body); // gonna have to add in building and stations
            })
        } else {
            //isn't admin
            resetRegisterError();
            registerError.manageFoodError="You aren't an admin";
            req.body.registerError = registerError;
            req.body.usernameValue = currentUser;
            res.render('home', req.body);
        }
    });
})

app.post('/managefood',(req, res)=> {
    console.log(req.body);
    connection.query(`call ad_filter_food('${req.body.foodName}','${req.body.sortName}','${req.body.sortDir}')` , (e, results, fields)=>{
        connection.query('select * from ad_filter_food_result', (e, results2, fields2)=>{
            res.end(JSON.stringify(results2));
        })
    })
})

app.post('/deletefood', (req,res)=>{
    console.log('hit');
    console.log(req.body);
    connection.query(`call ad_delete_food('${req.body.foodName}')`, (e, results, fields)=>{
        data = {};
        if (e) {
            console.log(e)
            data.response = "Error";
            res.end(JSON.stringify(data));
        } else {
            data.response = "OK";
            data.foodName = req.body.foodName;
            res.end(JSON.stringify(data));
        }
    })
})

//create food stuff
app.post('/createfoodpage', (req,res)=>{
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    res.render('createfood', req.body);
});

app.post('/createfood', (req, res)=>{
    console.log(req.body);
    connection.query(`call ad_create_food('${req.body.foodName}')`, (e, results, fields)=> {
        if (e) {
            console.log(e)
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            registerError.createFoodError = "Food already exists";
            req.body.registerError = registerError;
            res.render('createfood', req.body);
        } else {
            resetRegisterError();
            req.body.registerError = registerError;
            req.body.usernameValue = req.body.currentUser;
            res.render('home', req.body)
        }
    })
});

//manage food truck stuff
app.post('/managefoodtruckpage', (req, res)=>{
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    //need to get all stations
    //also need to check if user is manager 
    connection.query('select userType from login_classifier where username="' + req.body.currentUser + '";', (e, results, fields)=>{
        if(e) {
            console.log(e)
        } else {
            connection.query('select username from manager', (e1, results1, fields1)=>{
                let isManager=false;
                for (result of results1) {
                    if (result.username === req.body.currentUser) {
                        isManager=true;
                    }
                }
                if (!isManager) {
                    resetRegisterError();
                    registerError.mfError = "You aren't a manager";
                    req.body.usernameValue = req.body.currentUser;
                    req.body.registerError = registerError;
                    res.render('home', req.body);
                } else {
                    connection.query('select stationName from station', (e, stations, fields)=>{
                        req.body.stations = stations;
                        res.render('managefoodtrucks', req.body);
                    })
                }
            })
        }
    })
});

app.post('/managefoodtruck', (req, res)=>{
    if (req.body.staffCount1 === "") {
        req.body.staffCount1 = "NULL"  
    }
    if (req.body.staffCount2 === "") {
        req.body.staffCount2 = "NULL"  
    }
    let queryString = `call mn_filter_foodTruck('${req.body.username}','${req.body.foodTruckName}','${req.body.stationName}',${req.body.staffCount1},${req.body.staffCount2},${req.body.hasRemainingCapacity})`;
    connection.query(queryString, (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            connection.query('select * from mn_filter_foodTruck_result', (e, results2, fields2)=>{
                res.end(JSON.stringify(results2));
            })
        }
    }); 
});

//create foodtruck
app.post('/createfoodtruckpage', (req, res)=>{
    console.log(req.body);
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    //need to get all stations with positive remaining capacity, available staff(name and username), probably 2 queries
    let available_stations = 'select * from (SELECT capacity - count(Distinct foodTruckName) as remainingCapacity , stationName FROM station natural join foodtruck group by stationName) as innerResult where remainingCapacity > 0';
    let avaiable_staff = 'call mn_view_foodTruck_available_staff_username("","")';
    connection.query(available_stations, (e1, stations, fields1)=>{
        if (e1) {
            console.log(e1)
        } else {
            connection.query(avaiable_staff, (e2, results, fields2)=>{
                if (e2) {
                    console.log(e2);
                } else {
                    connection.query('select * from mn_view_foodTruck_available_staff_username_result', (e3, staff, fields3)=>{
                        if (e3) {
                            console.log(e3);
                        } else {
                            connection.query('select * from food', (e4,foods,fields4)=>{
                                resetRegisterError();
                                req.body.usernameValue = req.body.currentUser;
                                req.body.registerError = registerError;
                                req.body.staff = staff;
                                req.body.stations=stations;
                                req.body.foods = foods;
                                res.render('createfoodtruck', req.body);
                            })
                        }
                    })
                }
            })
        }
    })

});

app.post('/createfoodtruck', (req, res)=>{
    console.log(req.body);
    //create foodtruck
    connection.query(`call mn_create_foodTruck_add_station('${req.body.foodTruckName}','${req.body.stationName}','${req.body.currentUser}')`, (e, results, fields)=>{
        if (e) {
            console.log(e);
            //foodtruck name already exists
            let available_stations = 'select * from (SELECT capacity - count(Distinct foodTruckName) as remainingCapacity , stationName FROM station natural join foodtruck group by stationName) as innerResult where remainingCapacity > 0';
            let avaiable_staff = 'call mn_view_foodTruck_available_staff_username("","")';
            connection.query(available_stations, (e1, stations, fields1)=>{
                if (e1) {
                    console.log(e1)
                } else {
                    connection.query(avaiable_staff, (e2, results2, fields2)=>{
                        if (e2) {
                            console.log(e2);
                        } else {
                            connection.query('select * from mn_view_foodTruck_available_staff_username_result', (e3, staff, fields3)=>{
                                if (e3) {
                                    console.log(e3);
                                } else {
                                    connection.query('select * from food', (e4,foods,fields4)=>{
                                        resetRegisterError();
                                        registerError.createFoodTruckError = "Foodtruck already exists";
                                        req.body.usernameValue = req.body.currentUser;
                                        req.body.registerError = registerError;
                                        req.body.staff = staff;
                                        req.body.stations=stations;
                                        req.body.foods = foods;
                                        res.render('createfoodtruck', req.body);
                                    })
                                }
                            })
                        }
                    })
                }
            })
        } else {
            if(!req.body.staffMembers) {
                req.body.staffMembers=[];
            }
            req.body.staffMembers.forEach((staffMember)=>{
                connection.query(`call mn_create_foodTruck_add_staff('${req.body.foodTruckName}','${staffMember}')`, (e, results, fields)=>{
                    console.log(e);
                })
            })
            if (!req.body.foodName) {
                req.body.foodName = [];
                req.body.price = [];
            }
            req.body.foodName.forEach((food, index)=>{
                price = req.body.price[index];
                connection.query(`call mn_create_foodTruck_add_menu_item('${req.body.foodTruckName}',${price},'${food}')`, (e, results, fields)=>{
                    console.log(e);
                })
            })
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            req.body.registerError = registerError;
            res.render('home', req.body);
        }
    })
});

//foodtruck summary stuff
app.post('/foodtrucksummarypage', (req,res)=>{
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    connection.query('select * from manager', (e, managerUsernames, fields)=>{
        let isManager=false;
        managerUsernames.forEach(element=>{
            if(element.username === req.body.currentUser) {
                isManager = true;
            }
        })
        if (isManager) {
            connection.query(`call mn_get_station('${req.body.currentUser}')`, (e1, results, fields)=>{
                if (e1) {
                    console.log(e1);
                } else {
                    connection.query('select * from mn_get_station_result', (e2, stations, fields2)=>{
                        if (e2) {
                            console.log(e2);
                        } else {
                            req.body.stations = stations;
                            res.render('foodtrucksummary', req.body);
                        }
                    })
                }
            })
        } else {
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            registerError.ftsError = "You aren't a manager";
            req.body.registerError = registerError;
            res.render('home', req.body)
        }
    })
});

app.post('/foodtrucksummary', (req, res)=>{
    console.log(req.body);
    let queryString;
    if (req.body.firstDate === "" && req.body.lastDate ==="") {
        queryString = `call mn_filter_summary('${req.body.currentUser}','${req.body.foodTruckName}','${req.body.stationName}',NULL,NULL,'${req.body.sortedBy}','${req.body.sortedDir}')`;
    } else if (req.body.firstDate==="") {
        queryString = `call mn_filter_summary('${req.body.currentUser}','${req.body.foodTruckName}','${req.body.stationName}',NULL,'${req.body.lastDate}','${req.body.sortedBy}','${req.body.sortedDir}')`;
    } else if (req.body.lastDate==="") {
        queryString = `call mn_filter_summary('${req.body.currentUser}','${req.body.foodTruckName}','${req.body.stationName}','${req.body.firstDate}',NULL,'${req.body.sortedBy}','${req.body.sortedDir}')`;
    } else {
        queryString = `call mn_filter_summary('${req.body.currentUser}','${req.body.foodTruckName}','${req.body.stationName}','${req.body.firstDate}','${req.body.lastDate}','${req.body.sortedBy}','${req.body.sortedDir}')`;
    }
    console.log(queryString);
    connection.query(queryString, (e1, results, fields)=>{
        if (e1) {
            console.log(e1);
        } else {
            connection.query('select * from mn_filter_summary_result', (e2, tableResults, fields2)=>{
                if (e2) {
                    console.log(e2);
                } else {
                    console.log(tableResults);
                    res.end(JSON.stringify(tableResults));
                }
            })
        }
    })
});

app.post('/viewdetailpage', (req, res)=>{
    console.log(req.body);
    console.log(`call mn_summary_detail('${req.body.currentUser}','${req.body.foodTruckName}')`);
    if (Array.isArray(req.body.foodTruckName)) {
        req.body.foodTruckName = req.body.foodTruckName[req.body.foodTruckName.length - 1];
    }
    connection.query(`call mn_summary_detail('${req.body.currentUser}','${req.body.foodTruckName}')`,(e1, results, fields1)=>{
        if (e1) {
            console.log(e1);
        } else {
            connection.query('select * from mn_summary_detail_result', (e2, results2, fields2)=>{
                if (e2) {
                    console.log(e2);
                } else {
                    console.log(results2);
                    data = {
                        results2,
                        usernameValue: req.body.currentUser
                    };
                    res.render('summarydetail', data);
                }
            })
        }
    })
});

app.post('/explorepage', (req, res)=>{
    resetRegisterError();
    req.body.usernameValue = req.body.currentUser;
    req.body.registerError = registerError;
    let isCustomer = false;
    connection.query('select username from customer', (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            results.forEach(result=>{
                if (result.username === req.body.currentUser) {
                    isCustomer = true;
                }
            })
            if (isCustomer) {
                connection.query('select buildingName from building', (e1, buildings, fields1)=>{
                    if (e1) {
                        console.log(e1);
                    } else {
                        connection.query('select stationName from station', (e2, stations, fields2)=>{
                            if (e2) {
                                console.log(e2);
                            } else {
                                resetRegisterError();
                                req.body.usernameValue = req.body.currentUser;
                                req.body.stations = stations;
                                req.body.buildings = buildings;
                                req.body.registerError = registerError;
                                res.render('explore', req.body);
                            }
                        })
                    }
                })
            } else {
                console.log('isn"t customer')
                resetRegisterError();
                req.body.usernameValue = req.body.currentUser;
                registerError.exploreError = "You aren't a customer"
                req.body.registerError = registerError;
                res.render('home', req.body)
            }
        }
    })
});

app.post('/explore', (req, res)=>{
    connection.query(`call cus_filter_explore('${req.body.buildingName}','${req.body.stationName}','${req.body.tag}','${req.body.foodTruckName}','${req.body.food}')`, (e1, results1, fields1)=>{
        if (e1) {
            console.log(e1);
        } else {
            connection.query('select * from cus_filter_explore_result', (e2, results2, fields2)=>{
                if (e2) {
                    console.log(e2);
                } else {
                    console.log(results2);
                    res.end(JSON.stringify(results2));
                }
            })
        }
    })
});

app.post('/selectstation', (req,res)=>{
    connection.query(`call cus_select_location('${req.body.currentUser}','${req.body.stationName}')`, (e, results, fields)=>{
        data = {};
        if (e) {
            console.log(e);
            data.response = "Failed";
            res.end(JSON.stringify(data));
        } else {
            data.response = "Succeeded";
            res.end(JSON.stringify(data));
        }
    })
});

//for deleting foodtruck
app.post('/deletefoodtruck', (req, res)=>{
    connection.query(`call mn_delete_foodTruck('${req.body.foodTruckName}')`, (e, results, fields)=>{
        data = {};
        if (e) {
            console.log(e);
            data.result = "Failure";
            res.end(JSON.stringify(data));
        } else {
            data.result = "Success";
            res.end(JSON.stringify(data));
        }
    })
})

//current information
app.post('/currentinformation', (req, res)=>{
    let isCustomer=false;
    connection.query('select username from customer', (e, customers, fields)=>{
        customers.forEach(customer=>{
            if (customer.username === req.body.currentUser) {
                isCustomer = true;
            }
        })
        if (isCustomer) {
            connection.query(`call cus_current_information_basic('${req.body.currentUser}')`, (e1, results1, fields1)=>{
                if (e1) {
                    console.log(e1); 
                } else {
                    connection.query(`select * from cus_current_information_basic_result`, (e2, basicResults, fields2)=>{
                        if (e2) {
                            console.log(e2);
                        } else {
                            connection.query(`call cus_current_information_foodTruck('${req.body.currentUser}')`, (e3, results3, fields3)=>{
                                if (e3) {
                                    console.log(e3);
                                } else {
                                    connection.query('select * from cus_current_information_foodTruck_result', (e4, tableResults, fields4)=>{
                                        if (e4) {
                                            console.log(e4);
                                        } else {
                                            resetRegisterError();
                                            req.body.usernameValue = req.body.currentUser;
                                            req.body.registerError = registerError;
                                            req.body.tableResults = tableResults;
                                            req.body.basicResults = basicResults[0];
                                            console.log('basic results');
                                            console.log(req.body.basicResults);
                                            res.render('currentinformation', req.body)
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
        } else {
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            registerError.ciError = "You aren't a customer";
            req.body.registerError = registerError;
            res.render('home', req.body);
        }
    })
});

//orders
app.post('/orderpage', (req, res)=>{
    //get menuitems for foodtruck
    connection.query(`select foodName, price from menuitem where foodTruckName ="${req.body.foodTruckName}"`, (e1, menuitems, fields1)=>{
        if (e1) {
            console.log(e1);
        } else {
            resetRegisterError();
            req.body.usernameValue = req.body.currentUser;
            req.body.menuitems = menuitems;
            req.body.registerError = registerError;
            res.render('order', req.body);
        }
    })
})

app.post('/order', (req,res)=>{
    //get price of items, check if user has valid balance
    connection.query(`select * from menuitem where foodTruckName="${req.body.foodTruckName}"`, (e1, menuItems, fields1)=>{
        prices = {};
        let totalPrice = 0;
        req.body.quantity.forEach((element, index)=>{
            if (element !== "") {
                //check each menuitem for price
                menuItems.forEach((menuItem)=>{
                    if (menuItem.foodName === req.body.foodName[index]) {
                        prices[req.body.foodName[index]] = menuItem.price;
                        totalPrice += menuItem.price * parseInt(element);
                    }
                })
            }
        })
        //check if user has valid balance
        connection.query(`select balance from customer where username="${req.body.currentUser}"`, (e2, balance, fields2)=>{
            if (e2) {
                console.log(e2);
            } else {
                if (balance[0].balance < totalPrice) {
                    //render order page with error
                    resetRegisterError();
                    req.body.usernameValue = req.body.currentUser;
                    registerError.orderError = "Insufficient balance";
                    req.body.registerError = registerError;
                    req.body.menuitems = menuItems;
                    res.render('order', req.body);
                } else {
                    //complete order and render home or current info page
                    //first create the order
                    //then get most recent orderID from orders with this username
                    //then, for each food create an orderdetail
                    console.log(req.body);
                    connection.query(`call cus_order('${req.body.date}','${req.body.currentUser}')`, (e1, results1, fields1)=>{
                        if (e1) {
                            console.log(e1);
                        } else {
                            console.log('currentOrder');
                            let currentOrder = results1[0][0].val;
                            connection.query(`select orderID from orders where customerUsername="${req.body.currentUser}"`,(e2, orderIDs, fields2)=>{
                                if (e2) {
                                    console.log(e2);
                                } else {
                                    req.body.quantity.forEach((element, index)=>{
                                        if (element !=='') {
                                            let foodQuantity = parseInt(element);
                                            let food = req.body.foodName[index];
                                            console.log(foodQuantity);
                                            console.log(food);
                                            connection.query(`call cus_add_item_to_order('${req.body.foodTruckName}','${food}',${foodQuantity},${currentOrder})`, (e3, results3, fields3)=>{
                                                if (e3) {
                                                    console.log(e3);
                                                } else {
                                                    //order done, render current info page
                                                    
                                                }
                                            })
                                        }
                                    })
                                    connection.query(`call cus_current_information_basic('${req.body.currentUser}')`, (e1, results1, fields1)=>{
                                        if (e1) {
                                            console.log(e1); 
                                        } else {
                                            connection.query(`select * from cus_current_information_basic_result`, (e2, basicResults, fields2)=>{
                                                if (e2) {
                                                    console.log(e2);
                                                } else {
                                                    connection.query(`call cus_current_information_foodTruck('${req.body.currentUser}')`, (e3, results3, fields3)=>{
                                                        if (e3) {
                                                            console.log(e3);
                                                        } else {
                                                            connection.query('select * from cus_current_information_foodTruck_result', (e4, tableResults, fields4)=>{
                                                                if (e4) {
                                                                    console.log(e4);
                                                                } else {
                                                                    resetRegisterError();
                                                                    req.body.usernameValue = req.body.currentUser;
                                                                    req.body.registerError = registerError;
                                                                    req.body.basicResults = basicResults[0];
                                                                    req.body.tableResults = tableResults;
                                                                    res.render('currentinformation', req.body)
                                                                }
                                                            })
                                                        }
                                                    })
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            }
        })
    })
});

//order history
app.post('/orderhistory', (req, res)=>{
    //check if manager customer first
    console.log(req.body)
    let isCustomer = false;
    connection.query('select username from customer', (e, results, fields)=>{
        if (e) {
            console.log(e);
        } else {
            results.forEach(result=>{
                if (result.username === req.body.currentUser) {
                    isCustomer = true;
                }
            })
            if (isCustomer) {
                connection.query(`call cus_order_history('${req.body.currentUser}')`,(e1, results1, fields1)=>{
                    if (e1) {
                        console.log(e1);
                    } else {
                        connection.query(`select * from cus_order_history_result`, (e2, history, fields2)=>{
                            if (e2) {
                                console.log(e2);
                            } else {
                                console.log(history);
                                resetRegisterError();
                                console.log(req.body.currentUser);
                                req.body.usernameValue = req.body.currentUser;
                                req.body.registerError = registerError;
                                req.body.history = history;
                                res.render('orderhistory', req.body)
                            }
                        })
                    }
                })
            } else {
                resetRegisterError();    
                req.body.usernameValue = req.body.currentUser;
                registerError.historyError = "You aren't a customer";
                req.body.registerError = registerError;
                res.render('home', req.body);
            }
        }
    })
})

//static folder middleware, needs to come after routes because they should take preference
app.use(express.static(path.join(__dirname, 'public')));

//start server
app.listen(PORT, ()=> console.log('Server running'));
