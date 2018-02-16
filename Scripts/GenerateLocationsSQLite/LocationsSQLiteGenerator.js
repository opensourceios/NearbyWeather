'use strict'

const Promise = require('bluebird')
const fs = Promise.promisifyAll(require('fs'))
const path = require('path')
const sqlite3 = require('sqlite3').verbose()
const StreamArray = require('stream-json/utils/StreamArray')

class LocationsSQLiteGenerator {

  constructor(inputFilePath, templateFilePath, outputFilePath) {
    this.inputFilePath = inputFilePath
    this.templateFilePath = templateFilePath
    this.outputFilePath = outputFilePath
  }

  run() {
    const inputFilePath = path.join(__dirname, this.inputFilePath)
    const templateFilePath = path.join(__dirname, this.templateFilePath)
    const outputFilePath = path.join(__dirname, this.outputFilePath)

    const jsonStream = StreamArray.make()
    const db = new sqlite3.Database(outputFilePath)


    return fs.copyFile(templateFilePath, outputFilePath)
      .then((error) => {
        if (error) return error
        fs.createReadStream(inputFilePath).pipe(jsonStream.input)

        jsonStream.output.on('data', (index, value) => {
          db.run('INSERT INTO location(id, name, country, latitude, longitude) VALUES ($id, $name, $country, $latitude, $longitude)', {
            $id: value.index, 
            $name: value.name, 
            $country: value.country,
            $latitude: value.coord.lat, 
            $longitude: value.coord.lon
          }, (error) => {
            console.log('DB Write Error:', error)
          })
        })
        
        jsonStream.output.on('end', () => {
          console.log('All Objects Imported to DataBase')
        })
      })
  }
}

module.exports = LocationsSQLiteGenerator