'use strict'

const fs = require('fs-extra')
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

    fs.copySync(templateFilePath, outputFilePath)
    fs.createReadStream(inputFilePath).pipe(jsonStream.input)

    

    jsonStream.output.on('data', (object) => {
      db.run('INSERT INTO locations(id, name, country, latitude, longitude) VALUES ($id, $name, $country, $latitude, $longitude)', {
        $id: object.value.id,
        $name: object.value.name,
        $country: object.value.country,
        $latitude: object.value.coord.lat,
        $longitude: object.value.coord.lon
      }, (error) => {
        console.log('DB Write Error:', error)
      })
    })

    jsonStream.output.on('end', () => {
      console.log('Stream did end')
    })
  }
}

module.exports = LocationsSQLiteGenerator